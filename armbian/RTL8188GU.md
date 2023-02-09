sudo apt-get install build-essential git dkms
git clone https://github.com/McMCCRU/rtl8188gu.git
cd rtl8188gu
make
sudo make install
sudo reboot
