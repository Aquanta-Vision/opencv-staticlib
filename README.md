# opencv-staticlib — ios-simulator-4.11

OpenCV 4.11.0 built as static **arm64 iOS Simulator** libraries, the simulator
counterpart of the `ios-4.11` branch (device arm64). A device slice cannot
link into a simulator binary, and GitHub macOS runners only offer simulators,
so netxten-aquantavision's CI integration tests consume this branch
(`PLATFORM=SIMULATORARM64` in `make_iOS.sh` / `Dependencies.cmake`).

- Layout: `arm64-simulator/` is a standard CMake install prefix;
  `OpenCV_DIR` is `arm64-simulator/lib/cmake/opencv4`.
- Recipe: `install_deps_ios_simulator.sh` (run in CI by
  netxten-aquantavision's `build_ios_sim_deps.yml` on macos-26 / Xcode 26.2;
  exact SDK versions in `toolchain.txt`).
