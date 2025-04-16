#!/bin/sh
# 配置锁屏
BLANK='#00000000'
CLEAR='#ffffff00'
DEFAULT='#00897be6'
TEXT='#00897be6'
WRONG='#880000bb'
VERIFYING='#00564de6'

i3lock\
	--insidever-color=$CLEAR	\
	--ringver-color=$VERIFYING	\
	\
	--insidewrong-color=$CLEAR	\
	--ringwrong-color=$WRONG	\
	\
	--inside-color=$BLANK		\
	--ring-color=$DEFAULT		\
	--line-color=$BLANK		\
	--separator-color=$DEFAULT	\
	\
	--verif-color=$TEXT		\
	--wrong-color=$TEXT		\
	--time-color=$TEXT		\
	--date-color=$TEXT		\
	--layout-color=$TEXT		\
	--keyhl-color=$WRONG		\
	--bshl-color=$WRONG		\
	\
	--screen 1			\
	--blur 9			\
	--clock				\
	--indicator			\
	--time-str="%H:%M:%S"		\
	--date-str="%A, %Y-%m-%d"	\
	--keylayout 1

