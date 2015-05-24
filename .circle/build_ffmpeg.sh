set -x
set -e
if [ ! -e ffmpeg-2.6.3/ffmpeg ]; then
    sudo apt-get update
    sudo apt-get -y --force-yes install autoconf automake build-essential libass-dev libfreetype6-dev libgpac-dev \
         libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
         libxcb-xfixes0-dev pkg-config texi2html zlib1g-dev libx264-dev yasm
    wget http://ffmpeg.org/releases/ffmpeg-2.6.3.tar.bz2
    tar xjf ffmpeg-2.6.3.tar.bz2
    cd ffmpeg-2.6.3
    ./configure -- enable-libx264 --enable-gpl
    make
    sudo make install;
fi
