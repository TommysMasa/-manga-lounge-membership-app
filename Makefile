.PHONY: codegen-force
codegen-force:
	@echo "Generating code"
	@fvm flutter pub run build_runner build --delete-conflicting-outputs



.PHONY: clean-run
clean-run:
	@$(MAKE) _clean-run

.PHONY: _clean-run
_clean-run:
	@echo "🧹 Cleaning Flutter project..."
	@fvm flutter clean
	@echo "📦 Getting dependencies..."
	@fvm flutter pub get
	@echo "🍎 Installing iOS pods..."
	@cd ios && pod install
	@fvm flutter run
	fi
