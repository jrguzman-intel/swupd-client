#!/usr/bin/env bats

load "../../swupdlib"

t1_hash="24d8955d9952c3fcb2241b0f8d225205a5861cec9757b3a075d34810da9b08af"
t2_hash="e6d85023c5e619eb43d5cfbfdbdec784afef5a82ffa54e8c93bda3e0883360a3"

setup() {
  clean_test_dir
  tar -C "$DIR/web-dir/10" -cf "$DIR/web-dir/10/Manifest.MoM.tar" Manifest.MoM Manifest.MoM.signed
  tar -C "$DIR/web-dir/10" -cf "$DIR/web-dir/10/Manifest.os-core.tar" Manifest.os-core Manifest.os-core.signed
  tar -C "$DIR/web-dir/10" -cf "$DIR/web-dir/10/Manifest.test-bundle1.tar" Manifest.test-bundle1 Manifest.test-bundle1.signed
  tar -C "$DIR/web-dir/10" -cf "$DIR/web-dir/10/Manifest.test-bundle2.tar" Manifest.test-bundle2 Manifest.test-bundle2.signed
  sudo chown root:root "$DIR/web-dir/10/staged/$t1_hash"
  sudo chown root:root "$DIR/web-dir/10/staged/$t2_hash"
  tar -C "$DIR/web-dir/10" -cf "$DIR/web-dir/10/pack-test-bundle1-from-0.tar" staged/$t1_hash --exclude=staged/$t1_hash/*
  tar -C "$DIR/web-dir/10" -cf "$DIR/web-dir/10/pack-test-bundle2-from-0.tar" staged/$t2_hash
}

teardown() {
  pushd "$DIR/web-dir/10"
  rm *.tar
  popd
  sudo chown $(ls -l "$DIR/test.bats" | awk '{ print $3 ":" $4 }') "$DIR/web-dir/10/staged/$t1_hash"
  sudo chown $(ls -l "$DIR/test.bats" | awk '{ print $3 ":" $4 }') "$DIR/web-dir/10/staged/$t2_hash"
  sudo rmdir "$DIR/target-dir/usr/bin/"
  sudo rm "$DIR/target-dir/usr/foo"
}

@test "bundle-add add multiple bundles" {
  run sudo sh -c "$SWUPD bundle-add $SWUPD_OPTS test-bundle1 test-bundle2"

  echo "$output"
  [ "${lines[2]}" = "Attempting to download version string to memory" ]
  [ "${lines[3]}" = "Downloading packs..." ]
  [ "${lines[4]}" = "Downloading test-bundle1 pack for version 10" ]
  [ "${lines[5]}" = "Extracting pack." ]
  [ "${lines[6]}" = "Downloading test-bundle2 pack for version 10" ]
  [ "${lines[7]}" = "Extracting pack." ]
  [ "${lines[8]}" = "Installing bundle(s) files..." ]
  [ "${lines[12]}" = "Bundle(s) installation done." ]
  [ -d "$DIR/target-dir/usr/bin" ]
  [ -f "$DIR/target-dir/usr/foo" ]
}

# vi: ft=sh ts=8 sw=2 sts=2 et tw=80
