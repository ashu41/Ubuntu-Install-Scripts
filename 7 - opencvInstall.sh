#!/usr/bin/zsh

py2Ex=`which python2`
py2In=`python2 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())"`
py2Pack=`python2 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"`
py3Ex=`which python3`
py3In=`python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())"`
py3Pack=`python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"`

echo "Your PATH variable will be changed for the installation. Anaconda will be removed from the PATH because it messes the linkings and dependencies"
sudo echo

#This removes both Anaconda from the path. This is important as anaconda messes up a lot of the dependencies
export TEMP=$PATH
if [[ $(echo $PATH | grep conda) ]]; then
    export PATH=$(echo $PATH | tr ':' '\n' | grep -v "conda[2-9]\?" | uniq | tr '\n' ':')
fi

#Download opencv and contrib from repo if it doesn't exist
if [ ! -d "$opencv" ]; then
    git clone https://github.com/Itseez/opencv
fi
if [ ! -d "$opencv_contrib" ]; then
    git clone https://github.com/Itseez/opencv_contrib
fi
cd opencv
mkdir build
cd build

#Build tiff on as opencv supports tiff4, which is older version, which ubuntu has dropped
# This may work as CMAKE parameter
# -DCMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \

cmake -DCMAKE_BUILD_TYPE=RELEASE \
 -DCMAKE_INSTALL_PREFIX=/usr/local \
 -DBUILD_opencv_cvv=OFF \
 -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
 -DBUILD_NEW_PYTHON_SUPPORT=ON \
 -DPYTHON2_EXECUTABLE=$py2Ex \
 -DPYTHON2_INCLUDE_DIR=$py2In \
 -DPYTHON2_PACKAGES_PATH=$py2Pack \
 -DPYTHON3_EXECUTABLE=$py3Ex \
 -DPYTHON3_INCLUDE_DIR=$py3In \
 -DPYTHON3_PACKAGES_PATH=$py3Pack \
 -DWITH_TBB=ON \
 -DWITH_V4L=ON \
 -DWITH_QT=ON \
 -DWITH_OPENGL=ON \
 -DWITH_VTK=ON \
 -DWITH_IPP=OFF \
 -DWITH_CUDA=OFF \
 -DBUILD_TESTS=OFF \
 -DBUILD_TIFF=ON \
 -DBUILD_opencv_java=OFF \
 -DENABLE_AVX=ON \
 -DBUILD_opencv_freetype=OFF ..

echo "Press [Enter] to configure cmake"
read temp

# De-comment the next line if you would like an interactive cmake menu to check if everything is alright and make some tweaks
#ccmake ..

echo "making and installing"
make -j8
sudo make install

echo "finishing off installation"
sudo /bin/bash -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
sudo ldconfig

export PATH=$TEMP

echo "The installation just completed. If it shows an error in the end, kindly post an issue on the git repo"
