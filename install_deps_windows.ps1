#! /usr/bin/env pwsh

# Get script directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
Push-Location "$SCRIPT_DIR"  # Move to the parent directory of the script

# Function to manually build OpenCV for a given architecture
function Install-OpenCV {
    param(
        [string]$ARCH
    )

    Write-Output "Building OpenCV for $ARCH manually..."

    $tempFile = [IO.Path]::GetTempFileName()
    $vcvarsArg = if ($ARCH -eq "ARM64") { "x64_arm64" } else { "x64" }
    cmd /c " `"C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat`" $vcvarsArg && set > `"$tempFile`" "

    # Set environment variables
    Get-Content $tempFile | ForEach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            Set-Content "env:\$($matches[1])" $matches[2]
        }
    }
    Remove-Item $tempFile

    # Define paths
    $OpenCVRepo = "https://github.com/opencv/opencv.git"
    $BuildDir = "$PWD\build\Windows\opencv\$ARCH"
    $InstallDir = "$PWD\$ARCH"

    # Remove previous build and artifacts
    Remove-Item -Recurse -Force $BuildDir -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force $InstallDir -ErrorAction SilentlyContinue

    # Clone OpenCV repository
    Write-Output "Cloning OpenCV repository..."
    if (!(Test-Path opencv)) {
        git clone --depth 1 --branch 4.11.0 $OpenCVRepo
    }

    # Run CMake to configure the build
    Write-Output "Configuring OpenCV with CMake..."
    if ($ARCH -eq "ARM64") {
        cmake -S opencv -B $BuildDir `
            -G "Visual Studio 17 2022" `
            -T ClangCL `
            -A ARM64 `
            -DWITH_IPP=OFF `
            -DBUILD_TESTING=OFF `
            -DCMAKE_BUILD_TYPE=Release `
            -DCMAKE_SYSTEM_PROCESSOR=ARM64 `
            -DBUILD_LIST="core,imgproc,features2d,flann,calib3d,videoio,video,highgui" `
            -DCMAKE_BUILD_TYPE=Release `
            -DOPENCV_GENERATE_PKGCONFIG=ON `
            -DOPENCV_GENERATE_CONFIG_FILE=ON `
            -DBUILD_SHARED_LIBS=ON `
            -DBUILD_opencv_flann=ON `
            -DBUILD_opencv_calib3d=ON `
            -DBUILD_opencv_dnn=OFF `
            -DBUILD_opencv_features2d=ON `
            -DBUILD_opencv_photo=OFF `
            -DBUILD_opencv_objdetect=OFF `
            -DBUILD_opencv_ml=OFF `
            -DBUILD_opencv_video=ON `
            -DBUILD_opencv_videoio=ON `
            -DBUILD_opencv_highgui=ON `
            -DBUILD_opencv_gapi=OFF `
            -DWITH_CAROTENE=OFF `
            -DWITH_JASPER=OFF `
            -DWITH_IMGCODEC_HDR=OFF `
            -DWITH_IMGCODEC_PFM=OFF `
            -DWITH_IMGCODEC_PXM=OFF `
            -DWITH_IMGCODEC_SUNRASTER=OFF `
            -DWITH_QUIRC=OFF `
            -DBUILD_EXAMPLES=OFF `
            -DBUILD_TESTS=OFF `
            -DBUILD_PERF_TESTS=OFF `
            -DBUILD_DOCS=OFF `
            -DBUILD_OPENEXR=ON `
            -DBUILD_JPEG=ON `
            -DBUILD_PNG=OFF `
            -DWITH_PNG=OFF `
            -DBUILD_ZLIB=ON `
            -DBUILD_TIFF=ON `
            -DBUILD_OPENJPEG=ON `
            -DWITH_WEBP=OFF `
            -DBUILD_WEBP=OFF `
            -DBUILD_PROTOBUFF=OFF `
            -DWITH_PROTOBUF=OFF `
            -DWITH_ADE=OFF
    }
    else {
        cmake -S opencv -B $BuildDir `
            -G "Visual Studio 17 2022" `
            -T ClangCL `
            -DBUILD_TESTING=OFF `
            -DWITH_IPP=OFF `
            -DCMAKE_BUILD_TYPE=Release `
            -DBUILD_LIST="core,imgproc,features2d,flann,calib3d,videoio,video,highgui" `
            -DCMAKE_BUILD_TYPE=Release `
            -DOPENCV_GENERATE_PKGCONFIG=ON `
            -DOPENCV_GENERATE_CONFIG_FILE=ON `
            -DBUILD_SHARED_LIBS=ON `
            -DBUILD_opencv_flann=ON `
            -DBUILD_opencv_calib3d=ON `
            -DBUILD_opencv_dnn=OFF `
            -DBUILD_opencv_features2d=ON `
            -DBUILD_opencv_photo=OFF `
            -DBUILD_opencv_objdetect=OFF `
            -DBUILD_opencv_ml=OFF `
            -DBUILD_opencv_video=ON `
            -DBUILD_opencv_videoio=ON `
            -DBUILD_opencv_highgui=ON `
            -DBUILD_opencv_gapi=OFF `
            -DWITH_CAROTENE=OFF `
            -DWITH_JASPER=OFF `
            -DWITH_IMGCODEC_HDR=OFF `
            -DWITH_IMGCODEC_PFM=OFF `
            -DWITH_IMGCODEC_PXM=OFF `
            -DWITH_IMGCODEC_SUNRASTER=OFF `
            -DWITH_QUIRC=OFF `
            -DBUILD_EXAMPLES=OFF `
            -DBUILD_TESTS=OFF `
            -DBUILD_PERF_TESTS=OFF `
            -DBUILD_DOCS=OFF `
            -DBUILD_OPENEXR=ON `
            -DBUILD_JPEG=ON `
            -DBUILD_PNG=ON `
            -DBUILD_ZLIB=ON `
            -DBUILD_TIFF=ON `
            -DBUILD_OPENJPEG=ON `
            -DWITH_WEBP=OFF `
            -DBUILD_WEBP=OFF `
            -DBUILD_PROTOBUFF=OFF `
            -DWITH_PROTOBUF=OFF `
            -DWITH_ADE=OFF
    }

    # Build OpenCV
    Write-Output "Building OpenCV..."
    cmake --build $BuildDir --verbose --config Release

    # Install OpenCV
    Write-Output "Installing OpenCV..."
    cmake --install $BuildDir --prefix $InstallDir

    Write-Output "OpenCV installed at: $InstallDir"
}

# Build for both architectures
Install-OpenCV -ARCH "x64"
Install-OpenCV -ARCH "ARM64"

# Return to the original directory
Pop-Location
