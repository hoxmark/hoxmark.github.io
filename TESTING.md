# Testing Guide

This document explains how to test your al-folio site build and deployment.

## Overview

Your site is 280 commits behind the upstream al-folio template, but it's configured to build and deploy automatically via GitHub Actions. The changes made ensure compatibility with the latest dependencies and best practices.

## What Was Fixed

1. **Updated Gemfile**: Added missing upstream plugins:
   - `jekyll-regex-replace` - For advanced string replacement
   - `jekyll-tabs` - For tabbed content support
   - `css_parser` - For CSS optimization

2. **Updated GitHub Actions Workflow**:
   - Removed deprecated `mermaid.cli` (no longer needed)
   - Removed `--lsi` flag from build (causes memory issues)
   - Separated CSS purging into its own step
   - Updated to use `checkout@v4` and latest action versions
   - Added path filters to only build when relevant files change

3. **Created Test Scripts**: Two scripts to verify everything works

## Test Scripts

### 1. Build Test (`test-build.sh`)

Tests that your site builds successfully.

**With Docker (Recommended):**
```bash
./test-build.sh
```

**Without Docker (requires Ruby 3.2+):**
```bash
# Install rbenv or rvm first, then:
rbenv install 3.2.2
rbenv local 3.2.2
./test-build.sh
```

**What it tests:**
- Cleans previous builds
- Installs dependencies
- Builds the site with production settings
- Verifies output directory structure
- Checks for broken Liquid tags
- Reports build size

### 2. Deployment Verification (`verify-deployment.sh`)

Verifies your live site is accessible and working.

**Usage:**
```bash
# Test your site
./verify-deployment.sh

# Or specify a different URL
./verify-deployment.sh https://your-custom-domain.com
```

**What it tests:**
- Main page accessibility (HTTP 200)
- Blog page accessibility
- Projects page accessibility
- CSS file references
- Meta tags presence
- Response time (<3 seconds)

## GitHub Actions

Your site automatically builds and deploys when you push to the `master` branch.

**View build status:**
1. Go to https://github.com/hoxmark/hoxmark.github.io/actions
2. Check the latest "Deploy site" workflow run

**Trigger a manual build:**
```bash
# From your repository on GitHub:
Actions tab → Deploy site → Run workflow
```

Or push a change:
```bash
git add .
git commit -m "Test deployment"
git push
```

## Common Issues

### "Ruby version too old"

**Problem:** Local Ruby is 2.6.10 but 3.0+ required.

**Solutions:**
1. Use Docker: `./test-build.sh` (automatically uses Docker)
2. Upgrade Ruby with rbenv:
   ```bash
   brew install rbenv
   rbenv install 3.2.2
   rbenv global 3.2.2
   echo 'eval "$(rbenv init -)"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. Don't worry about local builds - GitHub Actions handles deployment with the correct Ruby version

### "Bundle install fails"

**Solution:** Make sure you're using Ruby 3.2+, then:
```bash
bundle update
bundle install
```

### Site builds but doesn't deploy

**Check:**
1. GitHub Pages is enabled: Settings → Pages → Source should be "gh-pages" branch
2. GitHub Actions has write permissions: Settings → Actions → General → Workflow permissions → "Read and write permissions"
3. Check workflow logs for errors: Actions tab → Latest run → View logs

## Next Steps

### Option 1: Keep Current Version (Recommended)
Your site works fine! No action needed unless you want new features.

### Option 2: Sync with Upstream
If you want the latest 280 commits from upstream:

```bash
# Review what's new
git log upstream/master --oneline | head -20

# Create a backup branch
git checkout -b backup-before-sync

# Attempt merge (may have conflicts)
git checkout master
git merge upstream/master

# If conflicts occur, resolve them, then:
git add .
git commit -m "Merge upstream changes"
```

**Warning:** Syncing may cause conflicts with your customizations. Only do this if you need specific new features.

## Monitoring

**Check deployment status:**
- Live site: https://hoxmark.github.io
- Build logs: https://github.com/hoxmark/hoxmark.github.io/actions
- Last deployment: Check "Deployments" section on main repo page

**Set up monitoring:**
- Run `./verify-deployment.sh` in a cron job
- Use GitHub Actions scheduled runs (add to workflow)
- Use a service like UptimeRobot for 24/7 monitoring

## Questions?

- Check workflow logs: https://github.com/hoxmark/hoxmark.github.io/actions
- Review al-folio docs: https://github.com/alshedivat/al-folio
- Test locally with: `./test-build.sh`
- Verify deployment: `./verify-deployment.sh`
