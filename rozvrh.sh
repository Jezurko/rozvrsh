#!/bin/bash

base="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
sourcefile="$base/muj_rozvrh.xml"
#this would be nice as a switch, but that is too much work this project
print_empty_days=true

vertical_delimiter='│'
horizontal_delimiter='―'

if [ $# -gt 2 ]
then
    echo "Invalid number of arguments ($#), only 1 argument is supported \
- path to timetable xml file."
    exit 1
fi

if [ $# -ge 1 ]
then
    sourcefile=$1
fi

if [ ! -f "$sourcefile" ]
then
    echo "File $sourcefile does not exist" >&2
    exit 1
fi

if [ $# -eq 1 ]
then
    new_source=$PWD/$1
    if [ "${1::1}" = "/" ]
    then
        new_source=$1
    else
        name=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
        old_script="${base}/$name"
        new_script="${base}/new_$name"
        sed "s/sourcefile=\".*\"/sourcefile=\"${new_source//\//\\/}\"/" "$old_script" > "$new_script"
    fi
    echo "New script version (with new source path) generated in \"$new_script\"."
fi

days=(Po Út St Čt Pá)

cols=$(tput cols)
begintime=$(grep -m 1 minhod "$sourcefile" | awk -F '[<>]' '{print $3}')
endtime=$(grep -m 1 maxhod "$sourcefile" | awk -F '[<>]' '{print $3}')
num_of_blocks=$(( (endtime-begintime) / 60 ))
block_width=$(( (cols-4) / num_of_blocks - 1))

function print_vertical_line {
    echo -n "   "
    #I don't understand why this is the correct arithmetics, but ¯\_(ツ)_/¯
    #cols - 4  was misbehaving on narrow terminal
    for ((i=0; i<(num_of_blocks * (block_width + 1) + 1); i++))
    do
        echo -n "$horizontal_delimiter"
    done
    echo
}

function print_empty_slot {
    for ((k=0; k<block_width; k++)); do echo -n "·"; done
    echo -n "$vertical_delimiter"
}

function print_row {
    row=$(echo "$1" | awk "/<radek num=\"$2\">/,/<\/radek>/ { print }")
    #get block length (times 12, idk why, ask IS) and room
    len_room='s/.*diff="([0-9][0-9]).*mistnostozn>(.*)<\/mistnostozn.*/\1, \2/'
    #get subject code and name
    code_name='s/.*<kod>(.*)<\/kod><nazev>(.*)<\/nazev>.*/\1, \2/'
    #get empty slots(breaks)
    empty='s/\s*<break.*diff="([0-9][0-9]).*/\1/'
    #the awk command concats lines created by len_room and code_name
    #it is stolen magic from https://stackoverflow.com/a/22702103
    blocks=$(echo "$row" | sed -r "$len_room;$code_name;$empty;t;d" |
            awk '/^[0-9][0-9].+/{printf "%s", $0", ";next}{print $0}')
    for i in {1..3}
    do
        if [ "$i" -eq 1 ] && [ "$2" -eq 1 ]
        then
            echo -n "$3 $vertical_delimiter"
        else
            echo -n "   $vertical_delimiter"
        fi
        while read -r line
        do
            #this is stolen from https://stackoverflow.com/a/45201229
            readarray -td ", " block <<<"$line, "; unset 'block[-1]';\
                declare -p block >/dev/null
            if [ "${#block[@]}" -eq 1 ]
            then
                print_empty_slot
            else
                slots=$((block[0] / 12))
                width=$((block_width * slots + slots - 1))
                empty_space=$((width - ${#block[$i]}))
                padding=$(( empty_space / 2 ))
                if [ $((empty_space % 2)) -eq 1 ]
                then
                    echo -n " "
                fi
                for ((ii=0; ii<padding; ii++)); do echo -n " "; done
                echo -n "${block[$i]}" | cut -z -c 1-$((width))
                for ((ii=0; ii<padding; ii++)); do echo -n " "; done
                echo -n "$vertical_delimiter"
            fi
        done <<< "$blocks"
        echo
    done
    print_vertical_line
}

function print_day {
    get_day="/<den id=\"$1\" rows=\"[0-9]\">/,/<\/den>/ { print }"
    day=$(awk "$get_day" "$sourcefile")
    if [ -n "$day" ]
    then
        #how many "rows" are there in a day - when the timetable has colisions
        rows=$(echo "$day" | grep '<den id' | sed 's/.*rows="//; s/">.*//')
        for i in $(seq 1 "$rows")
        do
            print_row "$day" "$i" "$1"
        done
    elif "$print_empty_days"
    then
        for i in {1..3}
        do
            if [ "$i" -eq 1 ]
            then
                echo -n "$1 $vertical_delimiter"
            else
                echo -n "   $vertical_delimiter"
            fi
            for ((ii=0; ii<num_of_blocks; ii++))
            do
                print_empty_slot
            done
            echo
        done
        print_vertical_line
    fi
}

function print_times {
    time_filter='/<hodiny>/,/<\/hodiny>/ { print }'
    time_get='s/.*<od>(.*)<\/od>.*/\1/'
    times=$(awk "$time_filter" "$sourcefile" | sed -r "$time_get;t;d")
    echo -n "   "
    for i in $times
    do
        echo -n "$i"
        for ((ii=0; ii<(block_width + 1 - ${#i}); ii++)); do echo -n " "; done
    done
    echo
}

print_times
print_vertical_line
for i in "${days[@]}"
do
    print_day "$i"
done
