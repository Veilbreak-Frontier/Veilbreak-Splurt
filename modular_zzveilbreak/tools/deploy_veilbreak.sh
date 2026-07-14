#!/bin/bash
# deploy_veilbreak.sh – part of the main deploy.sh chain
# Purpose: Copy TGUI assets to cache and fix PNG references in CSS files

set -e
set -x

DEPLOY_DIR="$1"

if [ -z "$DEPLOY_DIR" ]; then
    echo "Usage: $0 <deployment_directory>"
    exit 1
fi

cd "$DEPLOY_DIR"

echo "📦 Copying TGUI assets to cache/assets/..."
mkdir -p cache/assets
cp -r tgui/public/. cache/assets/

echo "🔧 Fixing spritesheet PNG references in CSS files..."
cd cache/assets

# Find all CSS files
for css_file in $(find . -name "*.css" -type f); do
    css_dir=$(dirname "$css_file")
    # Extract PNG filenames referenced in the CSS
    grep -oP "url\('([^']+\.png)'\)" "$css_file" | sed "s/url('\(.*\)')/\1/" | while read -r png_file; do
        target="$css_dir/$png_file"
        if [ ! -f "$target" ]; then
            # Search for the PNG elsewhere in the cache
            real_png=$(find . -name "$png_file" -type f | head -1)
            if [ -n "$real_png" ] && [ "$real_png" != "./$target" ]; then
                echo "📋 Copying $png_file from $real_png to $css_dir/"
                cp "$real_png" "$target"
            else
                echo "⚠️ Warning: PNG $png_file referenced in $css_file not found anywhere."
            fi
        fi
    done
done

echo "✅ Cache populated and PNG references fixed."
