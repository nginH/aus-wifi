
releaseall:
	flutter build windows --release
	flutter build macos --release

devmacos:
	flutter run -d macos


devlinux:
	flutter run -d linux


devwindows:
	flutter run -d windows


devall:
	flutter run -d macos
	flutter run -d linux
	flutter run -d windows
