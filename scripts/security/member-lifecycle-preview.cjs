// Only provision and verify the member lifecycle preview; never enable global cutover.
const fs=require('node:fs'),path=require('node:path'),{execFileSync}=require('node:child_process');
const project='simpleapp-5c1c6',root=path.resolve(__dirname,'../..');
async function main(){
 const cli=fs.realpathSync(execFileSync('which',['firebase'],{encoding:'utf8'}).trim()),session=require(path.resolve(path.dirname(cli),'../auth'));
 const token=await session.getAccessToken(session.getGlobalDefaultAccount().tokens.refresh_token,['https://www.googleapis.com/auth/cloud-platform']);
 async function api(url,options={},missing=false){const r=await fetch(url,{...options,headers:{Authorization:`Bearer ${token.access_token}`,'Content-Type':'application/json'},signal:AbortSignal.timeout(30000)});if(missing&&r.status===404)return null;if(!r.ok){const d=await r.json();throw Error(`Cloud HTTP ${r.status}: ${d.error?.message||'request failed'}`);}return r.json();}
 const post=(url,body)=>api(url,{method:'POST',body:JSON.stringify(body)}),email=`member-lifecycle@${project}.iam.gserviceaccount.com`,role=`projects/${project}/roles/memberLifecycleIdentity`;
 const configUrl=`https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/documents/config/memberLifecycle`,config=await api(configUrl,{},true);
 if(config?.fields?.serverOnly?.booleanValue===true)throw Error('Global cutover is already enabled; inspect first.');
 if(process.argv.includes('--provision')){
  if(execFileSync('git',['status','--porcelain','--','functions','firebase.json','scripts/security/member-lifecycle-preview.cjs'],{cwd:root,encoding:'utf8'}).trim())throw Error('Record canonical source first.');
  const sa=await api(`https://iam.googleapis.com/v1/projects/${project}/serviceAccounts/${email}`,{},true);if(sa?.disabled)throw Error('Runtime disabled');if(!sa)await post(`https://iam.googleapis.com/v1/projects/${project}/serviceAccounts`,{accountId:'member-lifecycle',serviceAccount:{displayName:'Member registration and own-account erasure'}});
  const permissions=['firebaseauth.users.get','firebaseauth.users.delete'],current=await api(`https://iam.googleapis.com/v1/${role}`,{},true);
  if(!current)await post(`https://iam.googleapis.com/v1/projects/${project}/roles`,{roleId:'memberLifecycleIdentity',role:{title:'Member lifecycle identity',includedPermissions:permissions,stage:'GA'}});else if(JSON.stringify([...current.includedPermissions].sort())!==JSON.stringify([...permissions].sort()))throw Error('Role permissions differ');
  const base=`https://cloudresourcemanager.googleapis.com/v1/projects/${project}`,policy=await post(`${base}:getIamPolicy`,{options:{requestedPolicyVersion:3}});
  for(const r of [role,'roles/datastore.user','roles/logging.logWriter','roles/eventarc.eventReceiver']){let b=policy.bindings.find(x=>x.role===r&&!x.condition);if(!b){b={role:r,members:[]};policy.bindings.push(b);}const m=`serviceAccount:${email}`;if(!b.members.includes(m))b.members.push(m);}await post(`${base}:setIamPolicy`,{policy});console.log('Dedicated keyless runtime provisioned; global cutover unchanged.');return;
 }
 const functions=[];for(const id of ['createMemberProfile','deleteMyAccount','retryMemberAccountDeletions','removeRetiredSubscription']){const f=await api(`https://cloudfunctions.googleapis.com/v2/projects/${project}/locations/us-central1/functions/${id}`);if(f.state!=='ACTIVE'||f.serviceConfig.serviceAccountEmail!==email)throw Error(`${id} verification failed`);functions.push({id,state:f.state,runtime:f.serviceConfig.serviceAccountEmail,source:f.buildConfig.source.storageSource,uri:f.serviceConfig.uri});}
 for(const f of functions.filter(x=>['createMemberProfile','deleteMyAccount'].includes(x.id))){const r=await fetch(f.uri,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({data:{}})});if((await r.json()).error?.status!=='UNAUTHENTICATED')throw Error('Anonymous caller was not rejected');}
 if(process.argv.includes('--enable-preview'))await api(`${configUrl}?updateMask.fieldPaths=previewEnabled`,{method:'PATCH',body:JSON.stringify({fields:{previewEnabled:{booleanValue:true}}})});
 const after=await api(configUrl,{},true);if(after?.fields?.serverOnly?.booleanValue===true)throw Error('Global cutover changed');
 const proof={verifiedAt:new Date().toISOString(),sourceCommit:execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),functions,serverOnly:false,previewEnabled:after?.fields?.previewEnabled?.booleanValue===true,anonymousRejected:true,noPrivateKeyCreated:true};fs.writeFileSync(path.join(root,'docs/member-lifecycle-preview-deployment.json'),JSON.stringify(proof,null,2)+'\n');console.log(JSON.stringify(proof,null,2));
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
