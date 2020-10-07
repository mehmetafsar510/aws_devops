#!/bin/bash


function assign_initial_values() {
	pos_row=10
	pos_col=10
	min_row=10
	min_col=10
	max_row=60
	max_col=60
	challenge_row=49
        challenge_col=49
	challenge_exist=0
	score=0
	speed="0.1"
	random_row=0
	random_col=0
}


function update_status_bar(){
	tput sc

	let label_status_bar_pos=$max_row+2

	tput cup $label_status_bar_pos $min_col; echo $1
	tput rc
}


function update_score_bar() {
        tput sc

	tput setf 6
        let label_score_bar_pos=$min_row-2

        tput cup $label_score_bar_pos $min_col; echo Your Score: $1
	tput setf 7
        tput rc
}


function game_window(){
	tput smso
	tput setf 3
        while ((  pos_col <= max_col ))
        do
                tput cup $min_row $pos_col; echo "_"
		tput cup $max_row $pos_col; echo "_"	
                let pos_col++
        done

	while ((  pos_row <= max_row ))
	do
		tput cup $pos_row $min_col; echo "|"
		tput cup $pos_row $max_col; echo "|"
		let pos_row++
	done

	tput rmso
	tput setf 7
	let pos_row=$min_row
	let pos_col=$min_col
	update_score_bar $score
	update_status_bar "Press an arrow key to start."
	sleep 2
	update_status_bar ".........go on.............."
}


function my_init() {
	assign_initial_values
	setterm -cursor off
	#tput rmso
	clear
	tput cup $pos_row $pos_col; echo O
}


function my_quit() {
	clear
	setterm -cursor on
	tput setf 7
	exit
}


function check_coordinates() {
	if (( $pos_row < $min_row+2 ))
	then 
		let pos_row=max_row-2
		update_status_bar "Crashed to wall. Press ENTER to Quit"
		read
		my_quit
	fi

        if (( $pos_row > $max_row-2 ))
        then 
		let pos_row=min_row+2
		update_status_bar "Crashed to wall. Press ENTER to Quit"
		read
		my_quit
        fi
        
	if (( $pos_col < $min_col+2 ))
        then 
		let pos_col=max_col-2
		update_status_bar "Crashed to wall. Press ENTER to Quit"
		read
		my_quit
	fi
        
	if (( $pos_col > $max_col-2 ))
        then 
		let pos_col=min_col+2
		update_status_bar "Crashed to wall. Press ENTER to Quit"
		read
		my_quit
	fi
}


function create_random_row_and_col() {
        local rnd_row
        local rnd_col

        let rnd_row=$max_row-$min_row-3
        let rnd_col=$max_col-$min_col-3

        random_row=$(( $RANDOM % rnd_row ))
        random_col=$(( $RANDOM % rnd_col ))

        let random_row=$random_row+$min_row
        let random_col=$random_col+$min_col
}


function create_challenge() {
	create_random_row_and_col	
	let challenge_row=$random_row 
	let challenge_col=$random_col

	tput sc
	tput setf 4
	tput cup $challenge_row $challenge_col; echo "@"	
	tput setf 7
	tput rc
	challenge_exist=1
}


function check_challenge_exist() {
	if (( (( $1 == $challenge_row )) && (( $2 == $challenge_col )) ))
	then
		challenge_exist=0
		let score++
		update_score_bar $score
		if (( score > 20 )); then
			speed="0.005"
		elif (( score > 15 )); then
			speed="0.01"
		elif (( score > 10 )); then
			speed="0.05"
		else
			speed="0.1"
		fi
	fi
}


my_init

game_window

create_random_row_and_col
let pos_row=$random_row
let pos_col=$random_col


while true
do
	trapKey=
	if IFS= read -d '' -rsn 1 -t $speed str; then
		while IFS= read -d '' -rsn 1 -t $speed chr; do
			str+="$chr"
		done
        	case $str in
			$'\E[A') trapKey=UP; new_dir=UP  ;;
			$'\E[B') trapKey=DOWN; new_dir=DOWN ;;
			$'\E[C') trapKey=RIGHT; new_dir=RIGHT ;;
			$'\E[D') trapKey=LEFT; new_dir=LEFT ;;
			q | $'\E') my_quit ;; #loop=false; exit 
        	esac
	fi

	check_coordinates

	prex=$pos_col
	prey=$pos_row

	case $new_dir in
		UP) let pos_row-- ;;
		DOWN) let pos_row++ ;;
		RIGHT) let pos_col++ ;;
		LEFT) let pos_col-- ;;
	esac

	tput cup $prey $prex; echo " "
	check_challenge_exist $pos_row $pos_col 
	if (( challenge_exist == 0 ))
	then
		create_challenge
	fi
        tput cup $pos_row $pos_col; echo "O"
done


my_quit