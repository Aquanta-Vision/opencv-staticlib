#! /bin/bash
set -euo pipefail

# Get the directory containing this script (BSD readlink has no -f, so resolve
# the hard way; this must also work when the script sits at the repo root).
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# The script lives at the repo root; run everything from there so the opencv
# checkout and the ./arm64-x64 install prefix land inside the checkout.
pushd "${SCRIPT_DIR}" > /dev/null

install_opencv_macos() {
  if [ ! -d opencv ]; then
    git clone --depth 1 --branch 4.11.0 https://github.com/opencv/opencv.git
  fi

  rm -rf ./build/macOS/opencv
  rm -rf ./install/macOS/opencv

  # PNG support is ON. libpng's bundled ARM NEON code is force-disabled with
  # PNG_ARM_NEON_OPT=0 because this is a single-invocation universal build:
  # 3rdparty/libpng/CMakeLists.txt sets TARGET_ARCH from CMAKE_OSX_ARCHITECTURES,
  # which is the literal "x86_64;arm64" here, so its "^(ARM|arm|aarch)" guard
  # never matches. The NEON sources are then left uncompiled while the arm64
  # slice still sees __ARM_NEON and emits calls to png_*_neon symbols, giving
  # "Undefined symbols for architecture arm64" at link time. Forcing
  # PNG_ARM_NEON_OPT=0 globally makes libpng use its plain C filter paths.
  # We only decode small 16-bit greyscale frame sequences, so the lost NEON
  # acceleration is irrelevant.
  cmake -G Ninja \
    -S opencv \
    -B ./build/macOS/opencv \
    -DCPU_BASELINE="" \
    -DCPU_DISPATCH="" \
    -DWITH_IPP=OFF \
    -DBUILD_opencv_apps=OFF \
    -DBUILD_LIST=core,imgproc,photo,features2d,flann,calib3d,videoio,video,highgui,imgcodecs \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_opencv_flann=ON \
    -DBUILD_opencv_calib3d=ON \
    -DBUILD_opencv_dnn=OFF \
    -DBUILD_opencv_features2d=ON \
    -DBUILD_opencv_photo=ON \
    -DBUILD_opencv_objdetect=OFF \
    -DBUILD_opencv_ml=OFF \
    -DBUILD_opencv_video=ON \
    -DBUILD_opencv_videoio=ON \
    -DBUILD_opencv_highgui=ON \
    -DBUILD_opencv_gapi=OFF \
    -DWITH_CAROTENE=OFF \
    -DWITH_JASPER=OFF \
    -DWITH_IMGCODEC_HDR=OFF \
    -DWITH_IMGCODEC_PFM=OFF \
    -DWITH_IMGCODEC_PXM=OFF \
    -DWITH_IMGCODEC_SUNRASTER=OFF \
    -DWITH_QUIRC=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTS=OFF \
    -DBUILD_PERF_TESTS=OFF \
    -DBUILD_DOCS=OFF \
    -DBUILD_OPENEXR=ON \
    -DBUILD_JPEG=ON \
    -DBUILD_PNG=ON \
    -DWITH_PNG=ON \
    -DBUILD_ZLIB=ON \
    -DBUILD_TIFF=ON \
    -DBUILD_OPENJPEG=ON \
    -DBUILD_WEBP=ON \
    -DBUILD_PROTOBUFF=OFF \
    -DWITH_PROTOBUF=OFF \
    -DWITH_ADE=OFF \
    -DCMAKE_C_FLAGS="-DPNG_ARM_NEON_OPT=0" \
    -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64"

  # Run CMake and build (Ninja is single-config; build type comes from
  # CMAKE_BUILD_TYPE=Release set at configure time).
  cmake --build ./build/macOS/opencv --verbose
  cmake --install ./build/macOS/opencv --prefix ./arm64-x64

  # Uncomment if you want to clean up
  # rm -rf ./opencv
}

install_opencv_macos

popd > /dev/null
