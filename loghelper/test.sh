#!/bin/bash

exit_script(){
    exit 1
}


echo $start_line

echo -e "\n#################################################\n";
echo "[1]: $1";
echo "[2]: $2";
echo "[3]: $3";

if [ $1 = . ]
then
	echo "current"

else
	echo "dir: $1"
	zipFilePath=$1
	zipFile=${zipFilePath%/*}
	zipName=${zipFilePath##*/}

	echo "path:$zipFile name=$zipName"

	# command cd $zipFile
	# command ls
fi

echo -e "\n#################################################\n\n";
exit_script

