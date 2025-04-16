#!/bin/bash
# 关闭 i3-nagbar
ids=$(i3-msg -t get_tree | jq  '.nodes[1].nodes[0].nodes[]|select(.window_type == "unknown" and .window_properties.class != "i3bar") | .window'|tr '\n' ' ');for i in $ids;do wmctrl -i -c $i ;done

