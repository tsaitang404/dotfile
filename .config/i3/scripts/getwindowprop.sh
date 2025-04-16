#!/bin/bash
# 获取窗口属性
info=$(xprop | grep -E '^WM_CLASS|^WM_NAME' | awk -F '=' '{print $2}' | tr '\n' ','|awk -F ','  '{print "class:"$2",instance:"$3",title:"$1}')
i3-nagbar -t warning -m "$info" -B 'Copy XWindows Info' "echo $info | xsel -b && exec ~/.config/i3/scripts/close_nagbar.sh"
