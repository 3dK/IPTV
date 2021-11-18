# Script to download latest IPTV files for PT, BE and Sport channels

proc update_link { tv id date } {
	return [join [list "https://iptvm3ulist.com/m3u/" $tv [format "%02d" $id] "_iptvm3ulist_com_" $date ".m3u"] ""]
}

set now [clock seconds]

foreach tv [list "pt" "be" "sp"] {
	
	set id 1
	set day 0
	set date [clock format $now -format "%d%m%y"]
	set m3u8 "/var/www/html/stuff/"
	
	
	while { $day >= -30 } {
		if { [catch {exec wget -q --spider [update_link $tv $id  $date]}] } {
			incr day -1
			set date [clock format [expr $now + 60*60*24*$day] -format "%d%m%y"]
		} else {
			switch $tv {
				"sp" {
					exec wget -q [update_link $tv $id  $date] -O ${m3u8}iptv_${tv}.m3u8
					exec echo \n >> ${m3u8}iptv_${tv}.m3u8
					
					while { ![catch {exec wget -q [update_link $tv [incr id] $date] -O - >> ${m3u8}iptv_${tv}.m3u8}] } {
						exec echo \n >> ${m3u8}iptv_${tv}.m3u8
					}
				}
				
				default {
					while { ![catch {exec wget -q --spider [update_link $tv $id  $date]}] } {
						exec wget -q [update_link $tv $id $date] -O ${m3u8}iptv_${tv}${id}.m3u8
						incr id
					}
				}
			}
			
			break
		}
	}
}
