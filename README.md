# BESM-666 Testing Environment

This repository contains tools, scripts, libraries and etc. required
for BESM-666 simulator functional testing

# How to build

```
mkdir -p BESM-Consortium
cd BESM-Consortium
git clone <this repo>
cmake -B build -S . -DBESM666_FAKEROOT=$PWD/../sysroot
cmake --build build --parallel <JOBS>
```
