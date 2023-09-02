#!/usr/bin/env bash
wget https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz
sudo tar xzf Python-2.7.9.tgz
cd Python-2.7.9
sudo ./configure --enable-optimizations
sudo make altinstall
sudo ln -sfn '/usr/local/bin/python2.7' '/usr/bin/python2'
