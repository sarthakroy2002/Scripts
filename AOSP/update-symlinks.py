#!/usr/bin/env python
#
# Copyright (C) 2024 Sarthak Roy
#
# SPDX-License-Identifier: Apache-2.0
#

input_file = 'proprietary-files.txt'
soc = 'mt6855'

with open(input_file, 'r') as infile:
    lines = infile.readlines()

with open(input_file, 'w') as outfile:
    for line in lines:
        line = line.strip()
        
        if f"/{soc}/" in line and "/etc/" not in line:

            sha1sum=''
            if '|' in line:
                sha1sum = '|'+line.split('|')[1]
                line=line.split('|')[0]

            line = line.split(';SYMLINK=')[0]
            parts = line.split(f'/{soc}/')
            
            if len(parts) == 2:
                symlink_path = f"{parts[0]}/{parts[1]}"
                symlink_path = symlink_path.lstrip('-')
                if "graphics.allocator" in symlink_path or "v3avpud" in symlink_path:
                    symlink_path = symlink_path.replace(f".{soc}", "")

                modified_line = f"{line};SYMLINK={symlink_path}{sha1sum}"
                
                outfile.write(modified_line + '\n')
            else:
                outfile.write(line + '\n')

        elif "audio.primary.mediatek" in line:
            sha1sum=''
            if '|' in line:
                sha1sum = '|'+line.split('|')[1]
                line=line.split('|')[0]
            symlink_path = line.replace("mediatek", f"{soc}")
            symlink_path = symlink_path.lstrip('-')
            modified_line = f"{line};SYMLINK={symlink_path}{sha1sum}"
            outfile.write(modified_line + '\n')

        elif "audio.r_submix.mediatek" in line:
            sha1sum=''
            if '|' in line:
                sha1sum = '|'+line.split('|')[1]
                line=line.split('|')[0]
            symlink_path = line.replace("mediatek", f"{soc}")
            symlink_path = symlink_path.lstrip('-')   
            modified_line = f"{line};SYMLINK={symlink_path}{sha1sum}"
            outfile.write(modified_line + '\n')

        elif "libSoftGatekeeper" in line:
            sha1sum=''
            if '|' in line:
                sha1sum = '|'+line.split('|')[1]
                line=line.split('|')[0]
            symlink_path = line.replace("libSoftGatekeeper", "gatekeeper.default")
            symlink_path = symlink_path.lstrip('-')
            modified_line = f"{line};SYMLINK={symlink_path}{sha1sum}"
            outfile.write(modified_line + '\n')

        elif "libMcGatekeeper" in line:
            sha1sum=''
            if '|' in line:
                sha1sum = '|'+line.split('|')[1]
                line=line.split('|')[0]
            symlink_path = line.replace("libMcGatekeeper", "gatekeeper.trustonic")
            symlink_path = symlink_path.lstrip('-')
            modified_line = f"{line};SYMLINK={symlink_path}{sha1sum}"
            outfile.write(modified_line + '\n')

        elif "kmsetkey.trustonic" in line:
            sha1sum=''
            if '|' in line:
                sha1sum = '|'+line.split('|')[1]
                line=line.split('|')[0]
            symlink_path = line.replace("kmsetkey.trustonic", "kmsetkey.default")
            symlink_path = symlink_path.lstrip('-')
            modified_line = f"{line};SYMLINK={symlink_path}{sha1sum}"
            outfile.write(modified_line + '\n')

        elif "sensors.mediatek.V2.0" in line:
            sha1sum=''
            if '|' in line:
                sha1sum = '|'+line.split('|')[1]
                line=line.split('|')[0]
            symlink_path = line.replace("sensors.mediatek.V2.0", f"sensors.{soc}")
            symlink_path = symlink_path.lstrip('-')
            modified_line = f"{line};SYMLINK={symlink_path}{sha1sum}"
            outfile.write(modified_line + '\n')
            
        else:
            outfile.write(line + '\n')
