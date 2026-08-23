# Veil-Miner
Veil ProgPOW miner with CPU mining support for Apple Silicon (ARM) and GPU mining via OpenCL and CUDA on Linux/Windows.

## Table of Contents
- [Requirements](#requirements)
- [Building on macOS (Apple Silicon)](#building-on-macos-apple-silicon)
- [Building on Linux](#building-on-linux)
- [Building on Windows](#building-on-windows)
- [Running the miner](#running-the-miner)
- [Verifying a download](#verifying-a-download)
- [Verifying the signature](#verifying-the-signature)
- [Notes](#notes)

---

## Requirements

### macOS (Apple Silicon — M1/M2/M3/M4)
```bash
brew install cmake boost@1.85 openssl@3 pkg-config git
```

### Linux (Ubuntu/Debian)
```bash
sudo apt-get install build-essential cmake libboost-all-dev libssl-dev git
```

### Nvidia GPUs (CUDA, any platform)
- **CUDA Toolkit 12.8 or newer** if you want to build CUDA support. 12.8 is the
  first release that can target Blackwell (RTX 50-series, `sm_120`).
- Stay on **12.x**. CUDA 13 dropped offline compilation for `sm_50` through
  `sm_70`, so a 13.x build will not run on GTX 900/10-series or Volta cards.
- Older toolkits still build: the arch list trims itself to whatever the
  detected toolkit accepts. You just will not get Blackwell support below 12.8.

### Windows
- [Visual Studio 2019 or 2022](https://visualstudio.microsoft.com/) with the **Desktop development with C++** workload
- [CMake 3.16+](https://cmake.org/download/)
- [Git for Windows](https://git-scm.com/download/win)
- [vcpkg](https://github.com/microsoft/vcpkg) for dependencies. The clone is pinned to
  the `2024.07.12` tag: it is the last baseline shipping boost 1.85, and newer boost
  removed the Process v1 API this code uses. A current vcpkg will not build the miner.
- **Nvidia GPU**: [CUDA Toolkit 11+](https://developer.nvidia.com/cuda-downloads)
- **AMD GPU**: AMD drivers include OpenCL — no extra install needed

---

## Building on macOS (Apple Silicon)

```bash
# 1. Clone the repo
git clone https://github.com/Veil-Project/Veil-Miner.git
cd Veil-Miner/veil-progpow-miner

# 2. Pull the cmake submodules
git clone https://github.com/ethereum/cable cmake/cable
git clone https://github.com/hunter-packages/disabled-mode cmake/Hunter/disabled-mode

# 3. Create build directory
mkdir build && cd build

# 4. Configure — CPU mining is auto-enabled on Apple Silicon
cmake -DETHASHCPU=ON -DETHASHCL=OFF -DETHASHCUDA=OFF ..

# 5. Build
make -j$(sysctl -n hw.logicalcpu)
```

Binary: `build/veilminer/veilminer`

---

## Building on Linux

```bash
# 1. Clone the repo
git clone https://github.com/Veil-Project/Veil-Miner.git
cd Veil-Miner/veil-progpow-miner

# 2. Pull the cmake submodules
git clone https://github.com/ethereum/cable cmake/cable
git clone https://github.com/hunter-packages/disabled-mode cmake/Hunter/disabled-mode

mkdir build && cd build

# GPU — OpenCL + CUDA (most common)
cmake -DETHASHCL=ON -DETHASHCUDA=ON -DETHASHCPU=OFF ..

# GPU — OpenCL only (AMD / Intel)
cmake -DETHASHCL=ON -DETHASHCUDA=OFF -DETHASHCPU=OFF ..

# CPU only
cmake -DETHASHCL=OFF -DETHASHCUDA=OFF -DETHASHCPU=ON ..

make -j$(nproc)
```

Binary: `build/veilminer/veilminer`

---

## Building on Windows

Open a **Developer Command Prompt for VS 2022** (or 2019).

### 1. Install vcpkg and dependencies
```cmd
git clone --branch 2024.07.12 https://github.com/microsoft/vcpkg.git C:\vcpkg
C:\vcpkg\bootstrap-vcpkg.bat
C:\vcpkg\vcpkg install boost-algorithm boost-array boost-asio boost-bind boost-container-hash boost-dll boost-exception boost-fiber boost-filesystem boost-format boost-lexical-cast boost-lockfree boost-multiprecision boost-process boost-smart-ptr boost-system boost-thread boost-throw-exception --triplet x64-windows
```

OpenSSL comes separately, not from vcpkg: the pinned baseline's openssl port downloads
build tools from msys2 mirrors that no longer host those files. Install
[Win64 OpenSSL v3.x](https://slproweb.com/products/Win32OpenSSL.html) (the full
installer, not the Light one) or `choco install openssl`, then pass
`-DOPENSSL_ROOT_DIR="C:\Program Files\OpenSSL-Win64"` on the cmake line.

### 2. Clone and prepare the miner
```cmd
git clone https://github.com/Veil-Project/Veil-Miner.git
cd Veil-Miner\veil-progpow-miner

git clone https://github.com/ethereum/cable cmake\cable
git clone https://github.com/hunter-packages/disabled-mode cmake\Hunter\disabled-mode

mkdir build
cd build
```

### 3. Configure

**Nvidia GPU (CUDA)**
```cmd
cmake -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake ^
  -DETHASHCL=ON -DETHASHCUDA=ON -DETHASHCPU=OFF ..
```

**AMD GPU (OpenCL only)**
```cmd
cmake -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake ^
  -DETHASHCL=ON -DETHASHCUDA=OFF -DETHASHCPU=OFF ..
```

**CPU only**
```cmd
cmake -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake ^
  -DETHASHCL=OFF -DETHASHCUDA=OFF -DETHASHCPU=ON ..
```

> For Visual Studio 2019 replace `"Visual Studio 17 2022"` with `"Visual Studio 16 2019"`

### 4. Build
```cmd
cmake --build . --config Release
```

Binary: `veilminer\Release\veilminer.exe`

---

## Running the miner

### CPU mining (macOS / Linux)
```bash
./build/veilminer/veilminer --cpu -P stratum+tcp://WALLET_ADDRESS@POOL_HOST:PORT
```

### GPU — OpenCL (AMD / Intel)
```bash
./build/veilminer/veilminer --opencl -P stratum+tcp://WALLET_ADDRESS@POOL_HOST:PORT
```

### GPU — CUDA (Nvidia)
```bash
./build/veilminer/veilminer --cuda -P stratum+tcp://WALLET_ADDRESS@POOL_HOST:PORT
```

### Windows (same flags, different path)
```cmd
veilminer\Release\veilminer.exe --cuda -P stratum+tcp://WALLET_ADDRESS@POOL_HOST:PORT
```

### Example (Yada Miners pool)
```bash
./build/veilminer/veilminer --cpu -P stratum+tcp://YOUR_VEIL_ADDRESS@veil.yadaminers.pl:3334
```

### Coming from t-rex or another miner
Most miners take the pool, wallet and password as separate flags. veilminer packs
them into one `-P` URL, so this:
```
t-rex.exe -o stratum+tcp://veil.yadaminers.pl:3334 -u YOUR_VEIL_ADDRESS -p x
```
becomes this:
```
veilminer --cuda -P stratum+tcp://YOUR_VEIL_ADDRESS@veil.yadaminers.pl:3334
```
If your pool wants a password, it goes after the wallet as `:x` inside the URL.
Yada Miners does not need one.

### HiveOS flight sheet
The release ships a ready made custom miner package, source in `hiveos/`. In the
flight sheet pick your coin and wallet, set the miner to Custom, and configure:

| Field | Value |
|---|---|
| Miner name | `veilminer` |
| Installation URL | `https://github.com/Veil-Project/Veil-Miner/releases/download/v1.1.3/veilminer-1.1.3.tar.gz` |
| Hash algorithm | `progpow-veil` |
| Wallet and worker template | `%WAL%` |
| Pool URL | `veil.yadaminers.pl:3334` |
| Pass | `x` |

The dashboard gets per card hashrate, temps, fans and share counts through the
miner's api. Anything in Extra config arguments is appended to the command line.

### Show all options
```bash
./build/veilminer/veilminer --help
```

---

## Verifying a download

Every release ships a `SHA256SUMS.txt` written by the same CI run that built the
archives, so you can confirm the file you downloaded is the one CI produced before
you run it or add an antivirus exclusion for it. Put it next to the archive and run:

```bash
# Linux
sha256sum -c SHA256SUMS.txt --ignore-missing

# macOS
shasum -a 256 -c SHA256SUMS.txt --ignore-missing
```

```powershell
# Windows, prints True when the zip matches its line in SHA256SUMS.txt
$zip = "veilminer-v1.1.3-windows-x64-cuda12.9.zip"
(Get-FileHash $zip).Hash.ToLower() -eq ((Get-Content SHA256SUMS.txt | Select-String $zip) -split '\s+')[0]
```

---

## Verifying the signature

The checksum file only proves your download matches what was published. It cannot prove
who published it, since anyone able to attach a release can also replace the sums file.
The signature is what covers that: `SHA256SUMS.txt.asc` is a detached signature made on
the maintainer's own machine, never in CI.

Import the key once:

```bash
gpg --keyserver keys.openpgp.org --recv-keys 5C2CFA030397FCD763F1A97BF8788EFB40E750E5
```

If GnuPG cannot reach the keyserver (some macOS builds of GnuPG 2.5 fail with
"Try again later"), fetch the key over plain HTTPS instead:

```bash
curl -s https://keys.openpgp.org/vks/v1/by-fingerprint/5C2CFA030397FCD763F1A97BF8788EFB40E750E5 | gpg --import
```

Then check the sums file against it:

```bash
gpg --verify SHA256SUMS.txt.asc SHA256SUMS.txt
```

You want `Good signature from "ohcee <donkeybabe123@hotmail.com>"` with this primary key
fingerprint:

```
5C2C FA03 0397 FCD7 63F1  A97B F878 8EFB 40E7 50E5
```

A warning that the key is not certified with a trusted signature is normal and only means
you have not personally certified it. The fingerprint match is the part that matters, so
compare it against a source you already trust rather than against the download page alone.

Order of operations: verify the signature on `SHA256SUMS.txt`, then verify your download
against `SHA256SUMS.txt`, then run it.

## Notes

- **DAG size**: At epoch 218 (block ~3.9M) the DAG is ~4.55 GB. GPU miners need a card with at least 6 GB VRAM. CPU miners need at least 8 GB RAM (16 GB+ recommended on macOS due to unified memory sharing with the OS).
- **DAG epoch parameters**: This miner uses Veil's correct epoch length — 5525 blocks before block 2,100,000, then 8175 blocks after. The DAG resets to epoch 0 at block 2,100,000 and grows more slowly (~750 MB/year) from there.
- **Apple Silicon thread affinity**: macOS ARM does not support hard CPU affinity. The miner uses scheduling hints instead — this is normal and no action is needed.
- **RTX 50-series (Blackwell)**: needs an **R570 or newer driver** at runtime, plus a
  binary built with CUDA 12.8+. On a working setup the miner logs
  `Pre-compiled period N CUDA ProgPow kernel for arch 12.0` on startup. If you see a
  compile error from NVRTC instead, the build used a toolkit older than 12.8.
- **CUDA runtime dependency**: the ProgPoW search kernel is compiled at runtime by
  NVRTC, so `libnvrtc.so.12` (Linux) or the matching `nvrtc64_*.dll` (Windows) must be
  present alongside a normal driver install. Windows release zips must ship that DLL.
- **Which cards a build supports**: CUDA builds bake in SASS for Maxwell through
  Blackwell (`sm_50` to `sm_120`) plus PTX for the newest arch, so future cards can
  still JIT. Pin a single architecture with `-DCOMPUTE=120` to build faster.
- **Hashrate reference**, measured in the field on v1.1.3, August 2026:

  | Device | Hashrate |
  |---|---|
  | RTX 5060 | ~24 Mh/s |
  | RTX 3080 | ~23 Mh/s |
  | RTX 3060 Ti | ~19 Mh/s |
  | RTX 3060 | ~14 Mh/s |
