# Makefile for deploying the Flutter web projects to GitHub
# from https://codewithandrea.com/articles/flutter-web-github-pages/

BASE_HREF = /$(OUTPUT)/
GITHUB_USER = devsticks
GITHUB_REPO = https://github.com/$(GITHUB_USER)/$(OUTPUT)
BUILD_VERSION := $(shell grep 'version:' pubspec.yaml | awk '{print $$2}')

# Deploy the Flutter web project to GitHub
deploy:
ifndef OUTPUT
	$(error OUTPUT is not set. Usage: make deploy OUTPUT=<output_repo_name>)
endif

	@echo "Clean existing repository"
	flutter clean || { echo "Flutter clean failed"; exit 1; }

	@echo "Getting packages..."
	flutter pub get || { echo "Flutter pub get failed"; exit 1; }

	@echo "Generating the web folder..."
	flutter create . --platform web || { echo "Flutter create failed"; exit 1; }

	@echo "Building for web..."
	flutter build web --base-href $(BASE_HREF) --release || { echo "Flutter build failed"; exit 1; }

	@echo "Deploying to git repository"
	cd build/web && \
	echo "Current directory: $(shell pwd)" && \
	echo "Listing files before Git operations:" && \
	ls -la && \
	git init && echo "Git init exited with code $$?" && \
	git checkout -b main && echo "Git checkout exited with code $$?" && \
	git config user.name "github-actions[bot]" && \
	git config user.email "github-actions[bot]@users.noreply.github.com" && \
	git config --unset-all http.https://github.com/.extraheader && \
	git add . && echo "Git add exited with code $$?" && \
	git commit -m "Deploy Version $(BUILD_VERSION)" && echo "Git commit exited with code $$?" && \
	git remote add origin https://x-access-token:${GITHUB_TOKEN}@github.com/$(GITHUB_USER)/$(OUTPUT).git && \
	echo "Git remote add exited with code $$?" && \
	git push -u -f origin main && echo "Git push exited with code $$?" && \
	echo "Deployment successful"

	@echo "✅ Finished deploy: $(GITHUB_REPO)"
	@echo "🚀 Flutter web URL: https://$(GITHUB_USER).github.io/$(OUTPUT)/"

.PHONY: deploy