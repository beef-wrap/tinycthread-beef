cd tinycthread
mkdir build
cd build
cmake ..
cmake --build .
cd ../..
move .\tinycthread\build\Debug\tinycthread.lib libs
move .\tinycthread\build\Debug\tinycthread.pdb libs