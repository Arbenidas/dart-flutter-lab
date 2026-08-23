#!/usr/bin/env bash
set -eu

expected_flutter='3.47.1'
expected_dart_prefix='3.13.'

if ! command -v fvm >/dev/null 2>&1; then
  printf '%s\n' 'Falta FVM. Instálalo desde https://fvm.app/documentation/getting-started/installation'
  exit 1
fi

flutter_version="$(fvm flutter --version --machine 2>/dev/null | sed -n 's/.*"frameworkVersion":"\([^"]*\)".*/\1/p')"
if [ "$flutter_version" != "$expected_flutter" ]; then
  printf 'Flutter esperado: %s; encontrado: %s\n' "$expected_flutter" "${flutter_version:-no instalado}"
  printf '%s\n' 'Ejecuta: fvm install 3.47.1'
  exit 1
fi

dart_version="$(fvm dart --version 2>&1 | sed -n 's/^Dart SDK version: \([^ ]*\).*/\1/p')"
case "$dart_version" in
  "$expected_dart_prefix"*) ;;
  *)
    printf 'Dart esperado: %s; encontrado: %s\n' "$expected_dart_prefix" "$dart_version"
    exit 1
    ;;
esac

printf 'Entorno correcto: Flutter %s · Dart %s\n' "$flutter_version" "$dart_version"
