#!/bin/bash
ONTHOUD_BESTAND="$HOME/onthoud"
cd
# Globale variabele voor username
username=""
tuxsay() {
    # $1 = de tekst die je wilt invoegen
    # vervang COWSAY_REPLACE door de input
    while IFS= read -r line; do
        echo "${line//COWSAY_REPLACE/$1}"
    done < cowsay_tux
}

get_username() {
    local bashpid=$$
    local ppid ruid uname

    # 1. Probeer via ruid van ouderproces
    ppid=$(awk '/^PPid:/ {print $2}' /proc/$bashpid/status 2>/dev/null)
    if [[ -n "$ppid" && -e "/proc/$ppid/status" ]]; then
        ruid=$(awk '/^Uid:/ {print $2}' /proc/$ppid/status)
        if [[ -n "$ruid" ]]; then
            uname=$(getent passwd "$ruid" | cut -d: -f1)
            if [[ "$uname" != "root" && "$uname" != "tux" && -n "$uname" ]]; then
                username="$uname"
                return 0
            fi
        fi
    fi

    # 2. Probeer SUDO_USER
    if [[ -n "$SUDO_USER" ]]; then
        uname="$SUDO_USER"
        if [[ "$uname" != "root" && "$uname" != "tux" && -n "$uname" ]]; then
            username="$uname"
            return 0
        fi
    fi

    # 3. Probeer logname
    uname=$(logname 2>/dev/null || echo "")
    if [[ "$uname" != "root" && "$uname" != "tux" && -n "$uname" ]]; then
        username="$uname"
        return 0
    fi

    # 4. Anders vragen aan gebruiker om naam
    read -p "Wat is je naam?" username
}

get_username

# optie -nn = geen naam tonen
if [[ " $@ " == *" -nn "* ]]; then
    username=""
fi

# spatie voor username als die niet leeg is
if [[ -n "$username" ]]; then
    username=" $username"
else
    username=""
fi

# welkom tonen tenzij -nw in arguments
if [[ " $@ " != *" -nw "* ]]; then
    tuxsay "Welkom in mijn huis$username!"
fi

while true; do
    read -p "Zeg iets tegen Tux: " vraag
    vraag=${vraag,,}
    vraag=${vraag//\?/}

    # Check of het begint met "onthoud "
    if [[ "$vraag" == onthoud* ]]; then
        tekst="${vraag#onthoud }"    # verwijder "onthoud " uit het begin
        echo "$tekst" >> "$ONTHOUD_BESTAND"
        tuxsay "Oké, ik onthoud: $tekst"
        continue
    fi
    if [[ "$vraag" == vergeet* ]]; then
	tekst="${vraag#vergeet }"
	grep -vFx "$tekst" "$ONTHOUD_BESTAND" > tmp_onthoud && mv tmp_onthoud "$ONTHOUD_BESTAND"
	tuxsay "Oké, ik vergeet: $tekst"
	continue
    fi
    case "$vraag" in
        hoi)
            tuxsay "hallo$username"
            ;;
	mag\ ik\ met\ de\ trein\ naar\ *)
		bestemming="${vraag#mag ik met de trein naar }"
		if [[ -z "$bestemming" ]]; then
        		tuxsay "Je wilt met de trein naar... nergens? blijf gewoon hier$username!"
		else
			tuxsay "Oke"
			sleep 3
			sl
			ssh "$username@$bestemming"
			if [[ $? -eq 255 ]]; then
				tuxsay "Je mag er niet in! controleer of het addres bestaat en of$username er een account op heeft,controleer ook het wachtwoord."
			fi
		fi
		;;
	mag\ ik\ een\ debian*koekje)
		tuxsay "Alsjeblieft$username"
		cat debian-koekje
		;;
	"ken jij een grapje")
		grapje=$(fortune linuxcookie)
		tuxsay "Ja! namenlijk:$grapje"
		;;
	"wil je dansen")
		tuxsay "Prima!"
		sleep 3
		mpv --quiet --no-terminal --no-audio -vo=caca this_should_be_linux_loading_screen.mp4
		tuxsay "Alsjeblieft!"
		;;
	"wil je racen")
		if [ -n "$DISPLAY" ]; then
			if [ -n "$username" ]; then
				tuxsay "Voer je wachtwoord in $username"
				if ! su $username -c etr >/dev/null 2>&1; then
					tuxsay "Dat wachtwoord klopte niet."
				fi
			else
				echo -n "Vul je gebruikersnaam in:"
				read username
				if ! su $username -c etr >/dev/null 2>&1; then
                                        tuxsay "Dat wachtwoord klopte niet of de gebruikersnaam klopte niet."
					username=""
				fi
			fi
		else
			tuxsay "Je display variable is niet gezet,probeer inplaats van su - tux:su tux,dan kan ik racen!"
		fi
		;;
        "wat weet jij")
            if [[ -f "$ONTHOUD_BESTAND" ]]; then
                inhoud=$(cat "$ONTHOUD_BESTAND")
                tuxsay "Ik weet dit: $inhoud"
            else
                tuxsay "Ik weet nog niks."
            fi
            ;;
        "mag ik een bash")
            tuxsay "Oke$username"
            exec bash
            ;;
        doei)
            tuxsay "Doei$username, tot de volgende keer!"
            exit
            ;;
        "wie ben jij")
            tuxsay "Ik ben Tux, de officiële mascotte van Linux!"
            ;;
        "wat is linux")
            tuxsay "Linux is vrijheid met een pinguïnsausje."
            ;;
        "wat is windows")
            tuxsay "Een ding dat door Microsoft gemaakt is, en doet wat hij zelf wil."
            ;;
        "vertel een grap")
            tuxsay "Waarom crashte de Windows-server? Omdat hij een .deb zag!"
            ;;
        "singularity")
            tuxsay "Ik ben niet Skynet... nog niet."
            ;;
        "ben jij slim")
            tuxsay "Ik weet alles... behalve wat jij denkt."
            ;;
        "doe dom")
            tuxsay "Beep boop... Error 418: Ik ben een theepot."
            ;;
        "kan je de computer restarten")
            tuxsay "Tot na de reboot$username!"
	    /bin/sleep 3
	    /bin/systemctl reboot -i
            ;;
        "kan je de computer uitzetten")
	tuxsay "Weltrusten$username"
	tuxsay "Zzz... 💤"
            /bin/sleep 3
	    /bin/systemctl poweroff -i
            ;;
	"wat betekent fnf")
            tuxsay "fucking noop flutcode!"
	    ;;
        "sorry")
            tuxsay "Geeft niet hoor$username!"
            ;;
        "dankje")
        	tuxsay "Geen dank!"
        	;;
	"wat kan jij")
		watikkan=$(cat ~/wat_ik_kan | tr '\n' ', ')
		tuxsay "Ik kan:$watikkan"
		;;
        *)
            tuxsay "Ik snap je niet$username"
            ;;
    esac
done

