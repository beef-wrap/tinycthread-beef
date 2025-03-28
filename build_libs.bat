mkdir libs
mkdir libs\debug
mkdir libs\release

cd tinycthread
mkdir build
cd build

cmake ..

cmake --build .
copy .\Debug\tinycthread.lib ..\..\libs\debug
copy .\Debug\tinycthread.pdb ..\..\libs\debug

cmake --build . --config=Release
copy .\Release\tinycthread.lib ..\..\libs\release