GREEN='\e[38;5;82m'
CYAN='\e[38;5;39m'
RED='\e[38;5;196m'
YELLOW='\e[93m'
PING='\e[38;5;198m'
BLUE='\033[0;34m'
NC='\033[0m'
BLINK='\e[5m'
HIDDEN='\e[8m'
cok=marlboro.txt
login(){
    curl -s -X POST --compressed -D - \
        --url 'https://www.marlboro.id/auth/login?ref_uri=/profile'\
        -H 'Accept-Language: en-US,en;q=0.9' \
        -H 'Connection: keep-alive' \
        -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
        -H 'Host: www.marlboro.id' \
        -H 'Origin: https://www.marlboro.id' \
        -H 'Referer: https://www.marlboro.id/' \
        -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.119 Safari/537.36' \
        -H 'X-Requested-With: XMLHttpRequest' \
        --data-urlencode 'email='$1'' \
        --data-urlencode 'password='$2''\
        --data-urlencode 'decide_csrf='$3'' \
        --data-urlencode 'ref_uri=%252Fprofile0' \
        --cookie-jar $cok -b $cok
}
get_point(){
    curl -s 'https://www.marlboro.id/profile' -b $cok -c $cok | grep -Po "(?<=<img src=\"/assets/images/icon-point-red.svg\"/><div class=\"point\">).*?(?=</div>)"
}
get_csrf(){
    curl -s -D - 'https://www.marlboro.id/auth/login?ref_uri=/profile' --cookie-jar $cok
}
get_csrf_question(){
	curl -s 'https://www.marlboro.id/discovered/passion-quiz/question-3' --cookie-jar $cok | grep -Po "(?<=name\=\"decide_csrf\" value\=\").*?(?=\" />)"
}
function get_free(){
	curl -s -X POST -D \
	--url 'https://www.marlboro.id/discovered/passion-quiz-insert' \
	-H 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:68.0) Gecko/20100101 Firefox/68.0' \
	-H "Accept: */*" \
	-H "Accept-Language: en-US,en;q=0.5" \
	-H "Referer: https://www.marlboro.id/auth/login?ref_uri=/maze-of-decision/online-maze-result/&result=getter" \
	-H "X-Requested-With: XMLHttpRequest" \
	-H "Cookie: deviceId=$1;decide_session=$2;" \
	--data-urlencode "answer=2" \
	--data-urlencode "decide_csrf=$csrf" &> /dev/null
}
printf "${YELLOW}"
wacing='y'
list='asu.txt'
printf "${NC}"
y=$(gawk -F: '{ print $1 }' $list)
x=$(gawk -F: '{ print $2 }' $list)
IFS=$'\r\n' GLOBIGNORE='*' command eval  'email=($y)'
IFS=$'\r\n' GLOBIGNORE='*' command eval  'passw=($x)'
for (( i = 0; i < "${#email[@]}"; i++ )); do
    emails="${email[$i]}"
    pw="${passw[$i]}"
    cok="${emails}.txt"
    tahan=$(expr $i % 10)
	decide_csrff=$(echo $(get_csrf) | grep -Po "(?<=name\=\"decide_csrf\" value\=\").*?(?=\" />)" | head -1)
	login $emails $pw $decide_csrff &> /dev/null
	sebelum=$(get_point)
	id=`echo $(get_csrf) | grep -Po "(?<= deviceId=).*?(?=; Max-Age=15552000; )"`
	csrf=`echo $(get_csrf) | grep -Po "(?<=<input type=\"hidden\" name=\"decide_csrf\" value=\").*?(?=\" />)" | head -1`
	gasken=`login $emails $pw $csrf`
	w=$(expr $i + 1)
	echo -en "${RED}[+]${GREEN}[${w}/${#email[@]}] ${CYAN}$emails | ${YELLOW}${sebelum} -> "
	for (( w = w; w < 40; w++ )); do
		sess=$(echo $gasken | grep -Po "(?<= decide_session=).*?(?=; path=/)")
		get_free $id $sess &
	done
	wait
	decide_csrf=$(echo $(get_csrf) | grep -Po "(?<=name\=\"decide_csrf\" value\=\").*?(?=\" />)" | head -1)
	ceklogin=$(login $emails $pw $decide_csrf)
	point=$(get_point)
	let "akhir=${point}-${sebelum}"
	echo -e " ${YELLOW}${point} | Nambah: ${GREEN}${akhir} ${RED}[+]${NC}"
	rm $cok
	rm ./--url
done
wait