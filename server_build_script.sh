#!/bin/sh

# parse arguments KEY=VALUE
while [ $# -gt 0 ]; do
  case "$1" in
    *=*)
      varname=$(echo "$1" | cut -d= -f1)
      varvalue=$(echo "$1" | cut -d= -f2-)
      eval "$varname=\"$varvalue\""
      ;;
  esac
  shift
done

# add a check that exits if the variables are not set and exit with an error message
if [ -z "$JEKYLL_DIR" ]; then
  echo "JEKYLL_DIR is not set. Exiting."
  exit 1
fi
if [ -z "$NGINX_DIR" ]; then
  echo "NGINX_DIR is not set. Exiting."
  exit 1
fi
if [ -z "$JEKYLL_BUILDER_IMAGE" ]; then
  echo "JEKYLL_BUILDER_IMAGE is not set. Exiting."
  exit 1
fi
if [ -z "$COUNCIL_NUMBER" ]; then
  echo "COUNCIL_NUMBER is not set. Exiting."
  exit 1
fi

# Remove JEKYLL_DIR if it exists and create a new one
if [ -d "$JEKYLL_DIR" ]; then
  rm -rf $JEKYLL_DIR
fi
mkdir -p $JEKYLL_DIR
git clone https://github.com/Cyberknight-Websites/cyberknight-council-template.git $JEKYLL_DIR
cd $JEKYLL_DIR
rm -rf $NGINX_DIR/council-$COUNCIL_NUMBER
mkdir -p $NGINX_DIR/council-$COUNCIL_NUMBER
docker run --rm -v $JEKYLL_DIR:/srv/jekyll -u $(id -u):$(id -g) $JEKYLL_BUILDER_IMAGE bundler exec ruby /srv/jekyll/_scripts/sync_data.rb --council $COUNCIL_NUMBER --url https://secure.cyberknight-websites.com
docker run --rm -v $JEKYLL_DIR:/srv/jekyll -u $(id -u):$(id -g) $JEKYLL_BUILDER_IMAGE bundler exec jekyll build
cp -r $JEKYLL_DIR/_site/* $NGINX_DIR/council-$COUNCIL_NUMBER