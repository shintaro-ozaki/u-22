get:
	cd project/ && flutter pub get

clean:
	cd project/ && flutter clean

run:
	cd project/ && flutter run -d "iPhone 14"


all-start:
	cd project && \
	cd ios && \
	pod deintegrate && \
	cd .. && \
	flutter clean && \
	flutter pub get && \
	flutter run -d "iPhone 14"