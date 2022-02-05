#!/bin/bash

if [ -z "$DOCKER_TAG" ]; then
    DOCKER_TAG="main"
fi

PARAMS=()

if [ -n "$NOPULL" ]; then
    PARAMS+=("--set" "global.imagePullPolicy=IfNotPresent")
fi

# shellcheck disable=SC2086
if ! helm upgrade --install --namespace curiefense --reuse-values \
    --set "curiefense.global.settings.docker_tag=$DOCKER_TAG" \
    --set "redis.image.tag=$DOCKER_TAG" \
    --wait --timeout 600s --create-namespace \
    "${PARAMS[@]}" "$@" curiefense .
then
    echo "curiefense deployment failure... "
    kubectl --namespace curiefense describe pods

    # Template generation
    helm template --debug --set "curiefense.global.settings.docker_tag=$DOCKER_TAG" "${PARAMS[@]}" "$@" curiefense ./
    # TODO(flaper87): Print logs from failed PODs
    exit 1
fi
