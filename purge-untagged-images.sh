#!/bin/bash
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <image_names>"
    echo "image names should be space-separated urls like gcr.io/org/image@digest"
    exit 1
fi
IFS=" "; read -ra imgArr <<< "$*"
for img in "${imgArr[@]}"; do
  digest=$(echo "$img" | cut -d'@' -f2)
  if [ -z "$digest" ]; then
    echo "Error: Image '$img' does not contain a digest."
    continue
  fi
  image=$(echo "$img" | cut -d'@' -f1)
  if [[ $image != ghcr.io* ]]; then
    echo "Skipping: $image does not start with 'ghcr.io'"
    continue
  fi

  digests=$(docker buildx inspect --raw $img | jq '.manifests.[].digest')
  echo "Found digests: ${digests[@]}"

  fqn=$(echo "$image" | cut -d'/' -f2-)
  org=$(echo "$fqn" | cut -d'/' -f1)
  repo=$(echo "$fqn" | cut -d'/' -f2- | sed  -e 's/\//%2f/g')
  echo "Purging untagged image: $image"
done
