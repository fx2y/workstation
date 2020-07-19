#!/usr/bin/env bash

setup_gcloud() {
	curl https://sdk.cloud.google.com | bash
	. '/home/abdullah/google-cloud-sdk/path.bash.inc'
	gcloud init
}
