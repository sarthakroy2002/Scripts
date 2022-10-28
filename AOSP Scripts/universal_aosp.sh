#!/usr/bin/env bash

BASE_DIR="$(pwd)"
SOURCEDIR="${BASE_DIR}/android"

# Set-up Git username & emailID
read -p 'Enter your Git username: ' username
read -p 'Enter your Git email-ID: ' emailID
echo
git config --global user.name "$username"
git config --global user.email "$emailID"

rm -rf "${SOURCEDIR}"
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

#Initializing aosp_based rom sources
echo "------------------------------------------------------"
echo "        Welcome Universal ROM Download Script        "
echo "                 Based on android 13                  "
echo "------------------------------------------------------"
echo
read -p "Do you need build environment set-up (Y/n)? be
case $be in
          [Yy] ) echo "Setting-Up Build environment"
                 echo "----------------------------"
#Build environment setup
sudo apt-get install git-core gnupg flex bison build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 libncurses5 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig
                 break;;
           [Nn] ) echo "You're good to go"
                  echo ------------------"
           break;;
           * ) echo "Invalid Response"
esac
done
echo "  ROMs LIST  "
echo "-------------"
echo "1) Pixelexperience"
echo "2) LineageOS"
echo "3) Evolution - X"
echo "4) Pixelextended"
echo "5) Corvus OS"
echo "6) CrDroid"
echo "7) CherishOS"
echo "8) SpiceOS"
echo "9) SuperiorOS"
echo "10) Project Exilir"
echo
read -p "Input your choice here: " ch
case $ch in
#Pixelexperience
            [1] ) echo "You choosed Pixelexperience Source"
                  echo "----------------------------------"
           read -p "Do you want to save some space? (Y/n) " Ny
           case $Ny in 
                      [Yy] ) echo "Doing Shallow Clone"
                  echo "-------------------"
                  repo init -u https://github.com/PixelExperience/manifest -b thirteen --depth=1
                  break;;
                  [Nn] ) echo "Doing Deep Clone"
                         echo "----------------"
                         repo init -u https://github.com/PixelExperience/manifest -b thirteen
                    break;;
                      * ) echo "Invalid Response"
           esac
           done
                   break;;
#LineageOS
             [2] ) echo "You choosed LineageOS Source"
                  echo "----------------------------------"
           read -p "Do you want to save some space? (Y/n) " Ny
           case $Ny in 
                      [Yy] ) echo "Doing Shallow Clone"
                  echo "-------------------"
                  repo init -u https://github.com/LineageOS/android.git -b lineage-20.0 --depth=1
                  break;;
                  [Nn] ) echo "Doing Deep Clone"
                         echo "----------------"
                         repo init -u https://github.com/LineageOS/android.git -b lineage-20.0
                    break;;
                      * ) echo "Invalid Response"
           esac
           done
                   break;;
#Evolution-X
             [3] ) echo "You choosed Evolution-X Source"
                  echo "----------------------------------"
           read -p "Do you want to save some space? (Y/n) " Ny
           case $Ny in 
                      [Yy] ) echo "Doing Shallow Clone"
                  echo "-------------------"
                  repo init -u https://github.com/Evolution-X/manifest -b tiramisu --depth=1
                  break;;
                  [Nn] ) echo "Doing Deep Clone"
                         echo "----------------"
                         repo init -u https://github.com/Evolution-X/manifest -b tiramisu
                    break;;
                      * ) echo "Invalid Response"
           esac
           done
                   break;;
#Pixelextended
             [4] ) echo "You choosed Pixelextended Source"
                  echo "----------------------------------"
           read -p "Do you want to save some space? (Y/n) " Ny
           case $Ny in 
                      [Yy] ) echo "Doing Shallow Clone"
                  echo "-------------------"
                  repo init -u https://github.com/PixelExtended/manifest -b trece --depth=1
                  break;;
                  [Nn] ) echo "Doing Deep Clone"
                         echo "----------------"
                         repo init -u https://github.com/PixelExtended/manifest -b trece
                    break;;
                      * ) echo "Invalid Response"
           esac
           done
                   break;;
#CorvusOS
             [5] ) echo "You choosed CorvusOS Source"
                  echo "----------------------------------"
           read -p "Do you want to save some space? (Y/n) " Ny
           case $Ny in 
                      [Yy] ) echo "Doing Shallow Clone"
                  echo "-------------------"
                  repo init -u https://github.com/Corvus-AOSP/android_manifest.git -b 13 --depth=1
                  break;;
                  [Nn] ) echo "Doing Deep Clone"
                         echo "----------------"
                         repo init -u https://github.com/Corvus-AOSP/android_manifest.git -b 13
                    break;;
                      * ) echo "Invalid Response"
           esac
           done
                   break;;
#CRdroid
             [6] ) echo "You choosed CRdroid Source"
                  echo "----------------------------------"
           read -p "Do you want to save some space? (Y/n) " Ny
           case $Ny in 
                      [Yy] ) echo "Doing Shallow Clone"
                  echo "-------------------"
                  repo init -u https://github.com/crdroidandroid/android.git -b 13.0 --depth=1
                  break;;
                  [Nn] ) echo "Doing Deep Clone"
                         echo "----------------"
                         repo init -u https://github.com/crdroidandroid/android.git -b 13.0
                    break;;
                      * ) echo "Invalid Response"
           esac
           done
                   break;;
#CherishOS
             [7] ) echo "You choosed CherishOS Source"
                  echo "----------------------------------"
           read -p "Do you want to save some space? (Y/n) " Ny
           case $Ny in 
                      [Yy] ) echo "Doing Shallow Clone"
                  echo "-------------------"
                      repo init -u https://github.com/CherishOS/android_manifest.git -b tiramisu --depth=1
                  break;;
                  [Nn] ) echo "Doing Deep Clone"
                         echo "----------------"
                             repo init -u https://github.com/CherishOS/android_manifest.git -b tiramisu
                    break;;
                      * ) echo "Invalid Response"
           esac
           done
                   break;;
#SpiceOS
             [8] ) echo "You choosed SpiceOS Source"
                  echo "----------------------------------"
           read -p "Do you want to save some space? (Y/n) " Ny
           case $Ny in 
                      [Yy] ) echo "Doing Shallow Clone"
                  echo "-------------------"
                  repo init -u https://github.com/SpiceOS/manifest -b 13 --depth=1
                  break;;
                  [Nn] ) echo "Doing Deep Clone"
                         echo "----------------"
                          repo init -u https://github.com/SpiceOS/manifest -b 13
                    break;;
                      * ) echo "Invalid Response"
           esac
           done
                   break;;
#SuperiorOS
             [9] ) echo "You choosed SuperiorOS Source"
                  echo "----------------------------------"
           read -p "Do you want to save some space? (Y/n) " Ny
           case $Ny in 
                      [Yy] ) echo "Doing Shallow Clone"
                  echo "-------------------"
                  repo init -u https://github.com/SuperiorOS/manifest.git -b thirteen --depth=1
                  break;;
                  [Nn] ) echo "Doing Deep Clone"
                         echo "----------------"
                         repo init -u https://github.com/SuperiorOS/manifest.git -b thirteen
                    break;;
                      * ) echo "Invalid Response"
           esac
           done
                   break;;
#Project-Exilir
             [10] ) echo "You choosed Project Exilir Source"
                  echo "----------------------------------"
           read -p "Do you want to save some space? (Y/n) " Ny
           case $Ny in 
                      [Yy] ) echo "Doing Shallow Clone"
                  echo "-------------------"
                  repo init -u https://github.com/Project-Elixir/manifest -b Tiramisu --depth=1
                  break;;
                  [Nn] ) echo "Doing Deep Clone"
                         echo "----------------"
                         repo init -u https://github.com/Project-Elixir/manifest -b Tiramisu
                    break;;
                      * ) echo "Invalid Response"
           esac
           done
                   break;;
             * ) echo "Invalid Response"
esac
done
echo
#Syncing repo.
echo "Syncing repo. from the source"
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
