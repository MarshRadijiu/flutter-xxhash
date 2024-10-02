cd ../src

cmake -DCMAKE_TOOLCHAIN_FILE=./w32_toolchain.cmake . 
make
mv libxxhash.dll libxxhash32.dll

rm -rf CMakeFiles
rm CMakeCache.txt
rm cmake_install.cmake
rm -rf CMakeFiles
rm libxxhash.dll.a
rm Makefile

cmake -DCMAKE_TOOLCHAIN_FILE=./w64_toolchain.cmake . 
make
mv libxxhash.dll libxxhash64.dll

rm -rf CMakeFiles
rm CMakeCache.txt
rm cmake_install.cmake
rm -rf CMakeFiles
rm libxxhash.dll.a
rm Makefile

cmake .
make

rm -rf CMakeFiles
rm CMakeCache.txt
rm cmake_install.cmake
rm -rf CMakeFiles
rm Makefile