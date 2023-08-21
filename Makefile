get:
	cd project/ && flutter pub get

clean:
	cd project/ && flutter clean

run:
	cd project/ && flutter run -d "iPhone 14 Pro Max"


all-start:
	cd project && \
	flutter clean && \
	flutter pub get && \
	flutter run -d "iPhone 14 Pro Max"