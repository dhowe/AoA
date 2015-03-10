#!/bin/sh

cd ../
export D=`date '+%m.%d.%y_%H.%M.%S'`
export FILE="aoa_src_${D}$1.zip";
echo creating $FILE...
jar cvf ${FILE} aoa *xml assets/*.txt bin/aoa-bak.sh
scp ${FILE} dchowe@rednoise.org:/home/dchowe/aoa-bak/
#mv ${FILE} bin/bak
cd -
