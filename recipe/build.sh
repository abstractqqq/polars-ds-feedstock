#!/bin/bash

set -euxo pipefail

if [[ ("${target_platform}" == "win-64" && "${build_platform}" == "linux-64") ]]; then
  # we need to add the generate-import-lib feature since otherwise
  # maturin will expect libpython DSOs at PYO3_CROSS_LIB_DIR
  # which we don't have since we are not able to add python as a host dependency
  cargo add pyo3 \
      --manifest-path Cargo.toml \
      --features "abi3-py38,extension-module,multiple-pymethods,generate-import-lib"
  maturin build --release --strip
  pip install target/wheels/polars-ds*.whl --target $PREFIX/lib/site-packages --platform win_amd64
else
  # Run the maturin build via pip which works for direct and
  # cross-compiled builds.
  $PYTHON -m pip install . -vv
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
