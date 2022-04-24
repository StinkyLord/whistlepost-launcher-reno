SHELL:=/bin/bash
include .env

.PHONY: all build launch

build:
	mvn verify

launch:
	java -jar target/dependency/org.apache.sling.feature.launcher.jar \
		-f target/slingfeature-tmp/feature-whistlepost.json

launch-local:
	java -jar target/dependency/org.apache.sling.feature.launcher.jar \
		-f target/slingfeature-tmp/feature-local.json
