#!/usr/bin/env bash

source hack/lib/image_lib.sh

#
# push_manifest_list <source_image> <push_image> [<arch1> <arch2> <archN>]
#
# push_manifest_list uses the pre-pushed images for each
# supported architecture and pushes a manifest list for each
# of the tags from the Travis CI envionment (created during
# the image push job).
#
function push_manifest_list() {
  push_image=$1; shift || fatal "${FUNCNAME} usage error"
  arches=$@

  image_name=$push_image # @TODO bug workaround
  docker_login $push_image

  if [[ -z $TRAVIS ]] ; then
    manifest_dryrun $push_image $@ && exit 0
  fi

  check_can_push || exit 0

  tags=$(get_image_tags)
  for tag in $tags; do
    images_with_arches=$(get_arch_images $push_image $tag $arches)
    DOCKER_CLI_EXPERIMENTAL="enabled" docker manifest create $push_image:$tag $images_with_arches
    DOCKER_CLI_EXPERIMENTAL="enabled" docker manifest push --purge $push_image:$tag
  done

}

function manifest_dryrun() {
  printf "\n manifest dry-run outside of CI env \n"
  export TRAVIS_BRANCH="dryrun"

  push_image=$1; shift
  arches=$@

  tags=$(get_image_tags)
  for tag in $tags; do
    images_with_arches=$(get_arch_images $push_image $tag $arches)
    printf "docker manifest create $push_image:$tag $images_with_arches\n"
    printf "docker manifest push --purge $push_image:$tag\n"
  done

}

function get_arch_images(){
    image=$1; shift || fatal "${FUNCNAME} usage error"
    tag=$1; shift || fatal "${FUNCNAME} usage error"
    arches="$@"
    for arch in $arches; do
        echo "$image-$arch:$tag"
    done
}

push_manifest_list "$@"
