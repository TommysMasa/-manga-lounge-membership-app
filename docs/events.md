# Event schedule

The Events tab reads generally published events and, for active server-verified Pro members, Pro early-access events from the `events` Firestore collection.
It displays upcoming and ongoing events in chronological order, grouped by the
venue's calendar month. Dates always use America/Los_Angeles, including DST.
The whole row opens a detail page; registration opens the supplied URL externally.
No fictional events are bundled into the production feed.

## Publishing an event

Use Entry-scanner → Events to create drafts and schedule Pro/general releases.
See `../entry-scanner/docs/event-management.md` for deployment and Website integration.
Keep the event ID when participant CSV import is added later.

Required fields:
- `title`: string
- `startsAt`: Firestore timestamp (absolute instant)
- `endsAt`: Firestore timestamp, strictly after startsAt
- `ticketUrl`: full HTTPS registration URL, such as the event's Luma page
- `published`: boolean; only `true` appears in the member app

Optional fields:
- `summary`: short plain text for the schedule
- `description`: plain text with paragraphs for the detail page
- `location`: string, defaults to Manga Lounge
- `imageUrl`: HTTPS flyer image; omitted from the schedule, shown in detail
- `registrationLabel`: button label; defaults to Get tickets
- `priceLabel`: displayed price, e.g. $15, From $10, or Free; missing prices show See ticket options

Create as unpublished, fill in the real event information, then publish.
Malformed published documents are omitted. Loading, retry, and empty states
are included. Past events are omitted when the list is rendered.

## Release

Deploy the updated Firestore rules before shipping the app. Both the membership
app and entry-scanner rule files contain the same events access policy, because
both projects target the same database. Members can read published events;
staff can manage events. Pro early access is enforced by the server subscription mirror and Firestore rules. This change does not deploy rules, publish events,
or ship an app release. Luma CSV import is available in Entry-scanner; attendance and return-visit dashboards are later steps.

Announcement pushes carrying an event ID resolve it against the authorized feed and open the current event detail. Unsaved test notifications use the existing flyer announcement screen.

## Ticket-link attribution

The detail button calls authenticated `createEventTicketLink` before opening the ticket page. The server rechecks publication, Pro access and event end time, records the member UID with an opaque random click ID, and puts that ID in Luma `utm_content`. Eventbrite links keep their existing affiliate parameters and currently track clicks only.

With free Luma, staff can upload the guest CSV through Entry-scanner Events, preview matching IDs and import them. A matched ID identifies the account that opened the link; it does not prove the buyer's identity if someone shared the link. Historical guest CSVs without these IDs stay unmatched. No automatic provider webhook is connected.
