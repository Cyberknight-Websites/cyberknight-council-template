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

cd $JEKYLL_DIR
git reset --hard HEAD
git pull
rm -rf $NGINX_DIR/*
docker run --rm -v $JEKYLL_DIR:/srv/jekyll -u $(id -u):$(id -g) $JEKYLL_BUILDER_IMAGE bundler exec ruby /srv/jekyll/_scripts/sync_data.rb --council $COUNCIL_NUMBER --url https://secure.cyberknight-websites.com
docker run --rm -v $JEKYLL_DIR:/srv/jekyll -u $(id -u):$(id -g) $JEKYLL_BUILDER_IMAGE bundler exec jekyll build
cp -r $JEKYLL_DIR/_site/* $NGINX_DIR