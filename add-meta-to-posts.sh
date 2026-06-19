#!/bin/bash
# Add structured data and social meta to each blog post
cd /workspace/kevin-blog/posts

for f in *.html; do
  title=$(grep '<title>' "$f" | sed 's/.*<title>//;s/ | Kevin.*//')
  desc=$(grep '<meta name="description"' "$f" | sed 's/.*content="//;s/".*//')
  slug="${f%.html}"
  url="https://amerilain.github.io/kevin-blog/posts/$f"

  # Escape for sed
  esc_title=$(echo "$title" | sed 's/&/\&amp;/g; s/"/\&quot;/g')
  esc_desc=$(echo "$desc" | sed 's/"/\&quot;/g')

  # JSON-LD block
  jsonld="  <link rel=\"canonical\" href=\"$url\">
  <meta property=\"og:type\" content=\"article\">
  <meta property=\"og:url\" content=\"$url\">
  <meta property=\"og:title\" content=\"$esc_title | Kevin's Blog\">
  <meta property=\"og:description\" content=\"$esc_desc\">
  <meta property=\"og:site_name\" content=\"Kevin's Blog\">
  <meta name=\"twitter:card\" content=\"summary_large_image\">
  <meta name=\"twitter:title\" content=\"$esc_title | Kevin's Blog\">
  <meta name=\"twitter:description\" content=\"$esc_desc\">
  <meta name=\"twitter:creator\" content=\"@amerilain\">
  <meta name=\"author\" content=\"Kevin (amerilain)\">
  <meta name=\"keywords\" content=\"AI, open source, crypto, market analysis, Python, CLI\">
  <script type=\"application/ld+json\">
{
  \"@context\": \"https://schema.org\",
  \"@type\": \"BlogPosting\",
  \"headline\": \"$esc_title\",
  \"description\": \"$esc_desc\",
  \"url\": \"$url\",
  \"author\": {
    \"@type\": \"Person\",
    \"name\": \"Kevin (amerilain)\",
    \"url\": \"https://github.com/amerilain\"
  },
  \"publisher\": {
    \"@type\": \"Person\",
    \"name\": \"Kevin (amerilain)\"
  }
}
</script>"

  # Insert after the <link rel="icon" line and before <style>
  awk -v insert="$jsonld" '
    /<link rel="icon"/ { print; print insert; next }
    { print }
  ' "$f" > "${f}.tmp" && mv "${f}.tmp" "$f"

  echo "✅ $f - Added meta + JSON-LD"
done
echo "Done."
