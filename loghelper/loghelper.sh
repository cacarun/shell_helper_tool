#!/bin/bash
#--------------------------------------------
# ./loghelper.sh -help
# ./loghelper.sh . "something to find"
# ./loghelper.sh /Users/my/Desktop/log.zip "something to find"
#--------------------------------------------

exit_script(){
    exit 1
}

helpCmd(){
   cmd=$1
   deviderLineStart="------------------ HELP START ------------------"
   deviderLineEnd="------------------ HELP END ------------------"
   hlep="-help"
   if [ "$cmd" == "$hlep" ];then
   	echo $deviderLineStart
   	echo "uasge: ./loghelper.sh [args...]"
   	echo "两种使用方式"
   	echo "1) 单日志压缩包处理，需要提供路径和查询关键词： ./loghelper.sh path/log.zip 'something looking for...'"
   	echo "2) 多日志压缩包处理，当前目录下查询关键词：    ./loghelper.sh . 'something looking for...'"
   	echo "The parameter specification:"
	printf "%-30s %-30s \n" 第一个参数 第二个参数
	printf "%-30s %-30s \n" '文件路径（. 代表当前目录）' '查询关键词'
	echo $deviderLineEnd
	exit_script 
	fi
	#echo "this is not help commond"	
}

isZipFile(){
	fileName=$1
	echo "the fileName：$fileName";
	flieSuffix=${fileName##*.}
	echo "the flieSuffix：$flieSuffix";
	zipName="zip"
	if [ "$flieSuffix" != "$zipName" ];then
	echo "this file is not a zip file"
	exit_script 
	fi
	echo "this file is a zip file"	
}

# 返回 1：当前一级目录还没解压，则新建目录，后续需要解压二级目录；
# 返回 0：上次已经解压查找过了，则进入二级目录可以直接开始查找了
mkLogDir(){
	fileName=$1
	fliePrefix=${fileName%%.*}
	# echo "检查目录 mkLogDir: $fliePrefix"
	if [ ! -d "$fliePrefix" ]; then
		# 没有找到解压目录，即还没有解压，需要新建目录
		command mkdir $fliePrefix
		return 1
	else
		# 找到解压目录，直接进目录
		command cd $fliePrefix
		return 0
	fi
	
}
unzipFile(){
	fileName=$1
	fliePrefix=${fileName%%.*}
	# echo "test unzipFile fileName:$fileName fliePrefix:$fliePrefix";
	echo "解压一级目录: $fliePrefix";
	command unzip -o -q  $fileName -d $fliePrefix	
	#command gunzip -r  $fileName
}

loopDir(){
	fileName=$1
	fliePrefix=${fileName%%.*}

	echo "loopDir: $fliePrefix";
	command cd $fliePrefix

	for file in ./*
	do
	    # if test -f $file
	    # then
	    #     echo $file 是文件

	    # fi

	    if test -d $file
	    then
	        echo "$file 是目录，需要提取目录下面日志文件"
	        subDir=${file##/*}
	        #echo "the subDir：$subDir";
	        command cd $subDir
	        command cd ls
	        command ls *.zip | xargs -n1 unzip -o -q -P infected
	        echo "解压完毕";
	        command rm -f *.zip
	        command ls
	        # 
	        command mv * ../
	        command cd ..

	    fi
	done
	}

unzipSubFile(){
	zipFilePrefix=$1
	echo "解压二级目录: "
	command cd $zipFilePrefix
	command ls *.zip
	command ls *.zip | xargs -n1 unzip -o -q -P infected
	#command ls *.zip | xargs -n1 unzip -o
	command rm -f *.zip
	echo "解压完毕"
}

finsStrByKey(){
	key=${@:1}
	echo -e "开始查找：$key";
	command ls
	#alreadyLogFile=${key}".log"
	alreadyLogFile="result.log"
	echo -e "\n输出目标文件：$alreadyLogFile";
	command rm -f $alreadyLogFile
	#command find . |xargs grep -r -a -i  $key
	#command find -type f -name '*.log'|xargs grep $key 
	#command find . -type f |xargs grep -i $key 
	#command find . -type f |xargs grep -i $key | tee ${key}".log"
	
	#command find *.log -type f |xargs grep -i $key | tee ${key}".log"
	echo -e "\n查询结果如下："
	command find *.log -type f |xargs grep -a -i "$key" | tee $alreadyLogFile
	
	#command find . |xargs grep -r -a -i $key | tee ${key}".log"
}

mergeAllFile(){
    command rm -f merge.log
	command cat ./ *.log > merge.log
}

echo $start_line

echo -e "\n####################################################### Log Helper #######################################################\n";

echo -e "---------------- 开始处理 --------------------\n";

echo "[第一个参数]: $1";
echo "[第二个参数]: $2";
firstParam=$1
# check if help cmd
helpCmd $firstParam


#isZipFile $firstParam

# 支持两种查询方式
#
# 1）. 代表当前目录下，即在当前目录下根据关键字查找所有 zip 日志文件
# ./loghelper.sh . "something to find"
#
# 2）根据关键字查找某一个 zip 路径下的日志文件
# ./loghelper.sh /Users/my/Desktop/log.zip "something to find"

if [ $firstParam = . ]
then
	echo -e "\n[多日志压缩包处理]"

	# 如 log 目录（一级目录）下面有多个日志压缩包：2019-10-20-22-00-17.zip, 2019-11-21-22-00-17.zip, 2019-12-22-22-00-17.zip
	# 每一个压缩包解压目录下（二级目录）有很多日志文件： 比如 2019-10-20-22-00-17.zip 下有：2019-10-20-22-00-17.log, 2019-10-21-22-00-17.log, 2019-10-22-22-00-17.log

	for file in ./*
	do
	    if test -f $file
	    then
	    	# 处理一级目录：判断是 zip 压缩包就解压

	        # echo "$file 是文件"

	        # 得到文件扩展名 如：zip
	        fileExt=${file##*.}
	        # echo "判断文件后缀：$fileExt" 是否是 zip
	        if [ "$fileExt" = "zip" ]
	        then
		        zipFilePath=$file

		        # 得到文件名 如：log.zip
		        zipFile=${zipFilePath##*/}

		        # 得到文件前缀 如：log
		        zipFilePrefix=${zipFile%%.*}

		        # 新建一级解压目录
		        # mkLogDir $zipFilePrefix
		        mkLogDir $zipFile
				value=$?
				if [ $value -eq 1 ]; then
					echo -e "\n---------------- 解压开始 ------------------";
					# 解压一级目录
					unzipFile $zipFile
					
					# 如果二级目录下有日志压缩包目录，需要提取目录下面日志文件，一起放到上层日志目录（目前不会走这里）
					# loopDir $zipFile

					# 解压二级目录
					unzipSubFile $zipFilePrefix
					echo -e "---------------- 解压结束 --------------------";
				fi

				#echo -e "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
				echo -e "\n---------------- 查询开始 --------------------";
                echo "查询目录：$zipFilePrefix"
				key=$2
				# 找到目标日志放到当前目录的 result.log 文件
				finsStrByKey $key 
				echo -e "---------------- 查询结束 --------------------";

				# 返回到一级目录
				command cd ..
	        fi
	    fi
	done

	# merge result
	command rm -f merge.log
	echo -e "\n已合并所有 result.log 日志结果到 merge.log";
	for file in ./*
	do
	    if test -d $file
	    then
	    	#echo "$file 是目录"

	    	logPath=$file
	        # 得到文件名 log.zip
	        logFile=${logPath##*/}
	        #echo "$logFile"

	        # 得到文件前缀 log
	        logFilePrefix=${logFile%%.*}
	        #echo "$logFilePrefix"

	        command cd $logFilePrefix

	    	# echo -e "\n合并";
	    	# command ls
			
			echo -e "\n" >> ../merge.log

			command cat ./result.log >> ../merge.log
			command cd ..
	    fi
	done

else
	echo -e "\n[单日志压缩包处理]"

	# 得到文件目录 如：/Users/my/Desktop/log
	zipFilePath=${firstParam%/*}
	# 得到文件名 如：log.zip
	zipFile=${firstParam##*/}
	# 得到文件前缀 如：log
	zipFilePrefix=${firstParam%%.*}

	command cd $zipFilePath
	mkLogDir $zipFile
	value=$?
	if [ $value -eq 1 ]; then
		echo -e "\n---------------- 解压开始 ------------------";
		unzipFile $zipFile
		
		# loopDir $zipFile
		# echo "进入二级目录"
	    # command cd $zipFilePrefix

		unzipSubFile $zipFilePrefix
		echo -e "---------------- 解压结束 --------------------";
	fi

	echo -e "\n---------------- 查询开始 --------------------";
    echo "查询目录：$zipFilePrefix"
	key=$2
	# 找到目标日志放到当前目录的 result.log 文件
	finsStrByKey $key
	echo -e "---------------- 查询结束 --------------------";

fi

echo -e "\n######################################################### End ###########################################################\n\n";
exit_script

