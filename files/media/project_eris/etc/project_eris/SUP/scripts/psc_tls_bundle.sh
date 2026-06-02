#!/bin/sh

# Runtime TLS trust-bundle management for PSC Store.
# Security model:
# - Download only fixed HTTPS URLs.
# - Verify each downloaded PEM with pinned SHA-256.
# - Never execute downloaded content.
# - Atomically replace trust files after verification.

PSC_TLS_KEY_DIR="${PSC_TLS_KEY_DIR:-/media/project_eris/etc/project_eris/SUP/keys}"
PSC_TLS_CACERT="${PSC_TLS_CACERT:-${PSC_TLS_KEY_DIR}/cacert.pem}"
PSC_TLS_R12="${PSC_TLS_R12:-${PSC_TLS_KEY_DIR}/r12.pem}"
PSC_TLS_E8="${PSC_TLS_E8:-${PSC_TLS_KEY_DIR}/e8.pem}"
PSC_TLS_BUNDLE="${PSC_TLS_BUNDLE:-/tmp/pscstore-ca-bundle.pem}"
PSC_TLS_STAMP="${PSC_TLS_STAMP:-/tmp/pscstore_tls_refresh.stamp}"
PSC_TLS_LOCKDIR="${PSC_TLS_LOCKDIR:-/tmp/pscstore_tls_bundle.lock}"
PSC_TLS_REFRESH_SECS="${PSC_TLS_REFRESH_SECS:-86400}"

PSC_TLS_CACERT_URL="https://curl.se/ca/cacert.pem"
PSC_TLS_R12_URL="https://letsencrypt.org/certs/2024/r12.pem"
PSC_TLS_E8_URL="https://letsencrypt.org/certs/2024/e8.pem"

# Pinned hashes for strict integrity checks.
# Update these in-source only after deliberate review.
PSC_TLS_CACERT_SHA256="f1407d974c5ed87d544bd931a278232e13925177e239fca370619aba63c757b4"
PSC_TLS_R12_SHA256="c6afa726f611cd87bb3c7b743567221782655db4c4f47e7c64993d1bbdaae8f3"
PSC_TLS_E8_SHA256="f2c0dde62e2c90e6332fa55af79ed1a0c41329ad03ecf812bd89817a2fc340a9"

psc_tls_log() {
  msg="$*"
  if command -v pe_log >/dev/null 2>&1; then
    pe_log "tls: $msg"
    return 0
  fi
  if [ "${PSCSTORE_LOGGING:-0}" = "1" ]; then
    echo "[tls] $msg"
  fi
  return 0
}

psc_tls_now_epoch() {
  date -u +%s 2>/dev/null
}

psc_tls_time_is_sane() {
  # 2026-01-01 00:00:00 UTC
  min_epoch=1767225600
  now_epoch="$(psc_tls_now_epoch)"
  [ -n "$now_epoch" ] || now_epoch=0
  [ "$now_epoch" -ge "$min_epoch" ] 2>/dev/null
}

psc_tls_sha256_file() {
  file="$1"
  [ -r "$file" ] || return 1
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" 2>/dev/null | awk '{print tolower($1)}'
    return $?
  fi
  if command -v busybox >/dev/null 2>&1; then
    busybox sha256sum "$file" 2>/dev/null | awk '{print tolower($1)}'
    return $?
  fi
  return 1
}

psc_tls_hash_matches() {
  file="$1"
  expected="$(printf "%s" "$2" | awk '{print tolower($0)}')"
  got="$(psc_tls_sha256_file "$file")" || return 1
  [ "$got" = "$expected" ]
}

psc_tls_pem_sane() {
  file="$1"
  min_size="$2"
  max_size="$3"
  [ -r "$file" ] || return 1
  sz="$(wc -c < "$file" 2>/dev/null)"
  [ -n "$sz" ] || return 1
  [ "$sz" -ge "$min_size" ] 2>/dev/null || return 1
  [ "$sz" -le "$max_size" ] 2>/dev/null || return 1
  grep -q "^-----BEGIN CERTIFICATE-----" "$file" 2>/dev/null || return 1
  grep -q "^-----END CERTIFICATE-----" "$file" 2>/dev/null || return 1
  return 0
}

psc_tls_pick_curl_bin() {
  if [ -x "/media/project_eris/etc/project_eris/SUP/binaries/psc_curl_static" ]; then
    echo "/media/project_eris/etc/project_eris/SUP/binaries/psc_curl_static"
    return 0
  fi
  if command -v curl >/dev/null 2>&1; then
    echo "curl"
    return 0
  fi
  return 1
}

psc_tls_pick_bootstrap_ca() {
  for p in \
    "${PSC_CURL_CA_BUNDLE:-}" \
    "$PSC_TLS_BUNDLE" \
    "$PSC_TLS_CACERT" \
    /etc/ssl/certs/ca-certificates.crt \
    /etc/ssl/cert.pem \
    /etc/pki/tls/certs/ca-bundle.crt
  do
    [ -n "$p" ] || continue
    [ -r "$p" ] || continue
    echo "$p"
    return 0
  done
  return 1
}

psc_tls_fetch_verified() {
  url="$1"
  dst="$2"
  expected="$3"
  min_size="$4"
  max_size="$5"

  [ -n "$url" ] || return 1
  [ -n "$dst" ] || return 1
  [ -n "$expected" ] || return 1

  if [ -r "$dst" ] && psc_tls_hash_matches "$dst" "$expected" && psc_tls_pem_sane "$dst" "$min_size" "$max_size"; then
    return 0
  fi

  curlbin="$(psc_tls_pick_curl_bin)" || {
    psc_tls_log "no curl binary available for trust update"
    return 1
  }

  tmp="$(mktemp /tmp/psc_tls_XXXXXX 2>/dev/null)" || return 1
  ca_path="$(psc_tls_pick_bootstrap_ca 2>/dev/null || true)"

  if [ -n "$ca_path" ] && [ -r "$ca_path" ]; then
    if ! "$curlbin" --proto "=https" --tlsv1.2 --fail --silent --show-error --location \
        --connect-timeout 8 --max-time 45 --cacert "$ca_path" -o "$tmp" "$url" >/dev/null 2>&1; then
      rm -f "$tmp" >/dev/null 2>&1 || true
      psc_tls_log "download failed for $url"
      return 1
    fi
  elif ! "$curlbin" --proto "=https" --tlsv1.2 --fail --silent --show-error --location \
      --connect-timeout 8 --max-time 45 -o "$tmp" "$url" >/dev/null 2>&1; then
    rm -f "$tmp" >/dev/null 2>&1 || true
    psc_tls_log "download failed for $url"
    return 1
  fi

  if ! psc_tls_hash_matches "$tmp" "$expected"; then
    rm -f "$tmp" >/dev/null 2>&1 || true
    psc_tls_log "hash verification failed for $url"
    return 1
  fi

  if ! psc_tls_pem_sane "$tmp" "$min_size" "$max_size"; then
    rm -f "$tmp" >/dev/null 2>&1 || true
    psc_tls_log "PEM validation failed for $url"
    return 1
  fi

  mkdir -p "$PSC_TLS_KEY_DIR" >/dev/null 2>&1 || true
  chmod 0644 "$tmp" >/dev/null 2>&1 || true
  mv -f "$tmp" "$dst" >/dev/null 2>&1 || {
    rm -f "$tmp" >/dev/null 2>&1 || true
    return 1
  }
  return 0
}

psc_tls_refresh_assets() {
  force=0
  case "${PSC_TLS_FORCE_REFRESH:-0}" in
    1|true|TRUE|yes|YES|on|ON) force=1 ;;
  esac

  if [ "$force" -ne 1 ]; then
    now_epoch="$(psc_tls_now_epoch)"
    last_epoch="$(cat "$PSC_TLS_STAMP" 2>/dev/null)"
    [ -n "$last_epoch" ] || last_epoch=0
    [ -n "$now_epoch" ] || now_epoch=0
    if [ "$now_epoch" -gt 0 ] 2>/dev/null &&
       [ "$last_epoch" -gt 0 ] 2>/dev/null &&
       [ $((now_epoch - last_epoch)) -lt "$PSC_TLS_REFRESH_SECS" ] 2>/dev/null; then
      return 0
    fi
  fi

  if ! psc_tls_time_is_sane; then
    psc_tls_log "clock not sane; skip remote trust refresh"
    return 0
  fi

  ok=0
  if psc_tls_fetch_verified "$PSC_TLS_CACERT_URL" "$PSC_TLS_CACERT" "$PSC_TLS_CACERT_SHA256" 200000 2000000 &&
     psc_tls_fetch_verified "$PSC_TLS_R12_URL" "$PSC_TLS_R12" "$PSC_TLS_R12_SHA256" 1000 50000 &&
     psc_tls_fetch_verified "$PSC_TLS_E8_URL" "$PSC_TLS_E8" "$PSC_TLS_E8_SHA256" 1000 50000; then
    ok=1
  fi

  if [ "$ok" -eq 1 ]; then
    now_epoch="$(psc_tls_now_epoch)"
    [ -n "$now_epoch" ] || now_epoch=0
    echo "$now_epoch" >"$PSC_TLS_STAMP" 2>/dev/null || true
    psc_tls_log "trust assets refreshed"
    return 0
  fi

  psc_tls_log "trust refresh failed; using last known-good trust files"
  return 1
}

psc_tls_build_bundle() {
  if psc_tls_hash_matches "$PSC_TLS_CACERT" "$PSC_TLS_CACERT_SHA256" &&
     psc_tls_hash_matches "$PSC_TLS_R12" "$PSC_TLS_R12_SHA256" &&
     psc_tls_hash_matches "$PSC_TLS_E8" "$PSC_TLS_E8_SHA256" &&
     psc_tls_pem_sane "$PSC_TLS_CACERT" 200000 2000000 &&
     psc_tls_pem_sane "$PSC_TLS_R12" 1000 50000 &&
     psc_tls_pem_sane "$PSC_TLS_E8" 1000 50000; then
    tmp="$(mktemp /tmp/psc_tls_bundle_XXXXXX 2>/dev/null)" || return 1
    if cat "$PSC_TLS_CACERT" "$PSC_TLS_R12" "$PSC_TLS_E8" >"$tmp" 2>/dev/null; then
      chmod 0644 "$tmp" >/dev/null 2>&1 || true
      mv -f "$tmp" "$PSC_TLS_BUNDLE" >/dev/null 2>&1 || {
        rm -f "$tmp" >/dev/null 2>&1 || true
        return 1
      }
      export PSC_CURL_CA_BUNDLE="$PSC_TLS_BUNDLE"
      return 0
    fi
    rm -f "$tmp" >/dev/null 2>&1 || true
  fi

  if psc_tls_hash_matches "$PSC_TLS_CACERT" "$PSC_TLS_CACERT_SHA256" &&
     psc_tls_pem_sane "$PSC_TLS_CACERT" 200000 2000000; then
    export PSC_CURL_CA_BUNDLE="$PSC_TLS_CACERT"
    return 0
  fi

  for p in /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem /etc/pki/tls/certs/ca-bundle.crt; do
    [ -r "$p" ] || continue
    if psc_tls_pem_sane "$p" 10000 5000000; then
      export PSC_CURL_CA_BUNDLE="$p"
      return 0
    fi
  done
  return 1
}

psc_tls_prepare_bundle() {
  if ! mkdir "$PSC_TLS_LOCKDIR" >/dev/null 2>&1; then
    # Another process is preparing trust files; use existing bundle if available.
    if [ -r "$PSC_TLS_BUNDLE" ]; then
      export PSC_CURL_CA_BUNDLE="$PSC_TLS_BUNDLE"
      return 0
    fi
    return 1
  fi

  mkdir -p "$PSC_TLS_KEY_DIR" >/dev/null 2>&1 || true
  psc_tls_refresh_assets || true
  rc=1
  if psc_tls_build_bundle; then
    rc=0
  fi

  rmdir "$PSC_TLS_LOCKDIR" >/dev/null 2>&1 || true
  return "$rc"
}
