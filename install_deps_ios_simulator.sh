#! /bin/bash
# Builds OpenCV 4.11.0 as static arm64 libraries for the iOS *Simulator*.
#
# This is the simulator counterpart of install_deps_ios.sh (branch ios-4.11,
# device arm64). The differences are intentional:
#   * -DCMAKE_OSX_SYSROOT=iphonesimulator targets the simulator SDK
#   * BUILD_LIST adds photo + imgcodecs, which netxten's
#     find_package(OpenCV COMPONENTS ...) requires and which the published
#     device build also contains.
#
# Built in CI by netxten-aquantavision's build_ios_sim_deps.yml workflow on
# macos-26 / Xcode 26.2; see toolchain.txt for the exact SDK versions.

# Get the directory containing this script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Push to parent directory of scripts folder
pushd "${SCRIPT_DIR}/.." > /dev/null

install_opencv_ios_simulator() {
  git clone --depth 1 --branch 4.11.0 https://github.com/opencv/opencv.git

  rm -rf ./build/iOS-simulator/opencv

  cmake -G Xcode \
    -S opencv \
    -B ./build/iOS-simulator/opencv \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT=iphonesimulator \
    -DCMAKE_OSX_ARCHITECTURES="arm64" \
    -DCMAKE_SYSTEM_PROCESSOR=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=13 \
    -DBUILD_OBJC=OFF \
    -DSWIFT_DISABLED=1 \
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
    -DBUILD_ZLIB=ON \
    -DBUILD_TIFF=ON \
    -DBUILD_OPENJPEG=ON \
    -DBUILD_WEBP=ON \
    -DBUILD_PROTOBUFF=OFF \
    -DWITH_PROTOBUF=OFF \
    -DWITH_ADE=OFF

  cmake --build ./build/iOS-simulator/opencv --config Release
  cmake --install ./build/iOS-simulator/opencv --config Release --prefix ./arm64-simulator
}

install_opencv_ios_simulator

popd > /dev/null
