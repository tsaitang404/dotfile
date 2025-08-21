if [ !"$(ps -ef | grep feh |grep -v grep)" ];then
	echo 1
	feh --bg-fill ~/.background.png
fi
