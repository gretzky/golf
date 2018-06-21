#!/bin/sh
# golf.sh: a faster way to init a project
# https://github.com/gretzky/golf

VERSION=1.0.0

# set vars
t=$(mktemp -t golftemp) || exit
trap "rm -f $tempfile" EXIT
trap "exit 127" HUP STOP TERM

##############
# welcome msg
##############
dialog --title "welcome to golf" \
       --msgbox "\ngolf is a faster way to init a project\n" 10 50

##############
# proj details
##############
it=$(mktemp -t golftemp.project) || exit
dialog --title "project details" \
       --inputbox \
       "\nenter a name for your project:" 10 50 2>"$it"

retval=$?
proj=$(cat "$it")

case $retval in
    0 ) mkdir "$proj"
        ;;
    1 ) :
        ;;
esac

########
# readme
########
generate_readme() {
    URL="https://gist.githubusercontent.com/gretzky/19f241a2db9f119853019a40be8d0242/raw/702ce9ec40a51cbf3563047f6ea593a2ff637c4b/readme.md"
    curl "$URL" -o $proj/README.md >/dev/null 2>&1
    sleep 1
    echo "# $proj\n" | cat - $proj/README.md | sponge $proj/README.md
}

generate_readme

dialog --title "README.md" \
       --msgbox "generated a basic README in $proj" 10 50

###########
# gitignore
###########
os=""
lang=""
ide=""
other=""
exec 3>&1
dialog --title ".gitignore" \
        --form "\nAdd gitignore entries" \
15 50 0 \
        "OS:" 1 1 "$os"         1 10 40 0 \
        "Language:"    2 1 "$lang"        2 10 40 0 \
        "IDE/Text Editor:"    3 1 "$ide"       3 10 40 0 \
        "Other:"     4 1 "$other"         4 10 40 0 \
2>&1 1>&3 | {
    read -r os
    read -r lang
    read -r ide
    read -r other

    combined="$(echo ${os},${lang},${ide},${other})"
    output="$(echo "${combined}" | tr -d '[:space:]')"

    curl -L -s "https://www.gitignore.io/api/$output" >> $proj/.gitignore
}
exec 3>&-

##############
# editorconfig
##############
cat > $proj/.editorconfig <<- EOM
# editorconfig.org

root = true

[*]
end_of_line = lf
insert_final_newline = true
charset = utf-8
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false
EOM

run_config() {
    lang=""
    style=""
    size=""
    exec 3>&1
    dialog --title ".editorconfig" \
            --form "\nconfigure language-specfic settings:\n" \
    16 80 0 \
            "file extension:" 1 1 "$lang" 1 16 80 0 \
             "indent style:" 2 1 "$style" 2 16 80 0 \
            "indent size:" 3 1 "$size" 3 16 80 0 \
    2>&1 1>&3 | {
        read -r lang
        read -r style
        read -r size

        echo "\n[*.$lang]\nindent_style = ${style}\nindent_size = ${size}" >> $proj/.editorconfig
    }
    exec 3>&-
}

language_specific_editorconfig() {
    run_config
    dialog --title ".editorconfig" \
            --yesno "\ndo you need to configure any other language-specific settings?" 10 50
    
    case $? in
        0 ) run_config
            ;;
        1 ) :
            ;;
    esac
}

dialog --title "editorconfig" \
       --yesno "\ndo you need to configure language-specific editorconfig settings?" 10 50

case $? in
    0 ) language_specific_editorconfig
        ;;
    1 ) :
        ;;
esac

#########
# license
#########
get_license() {
    if ! jq_loc="$(type -p "jq")" || [[ -z $jq_loc ]];
    then
        dialog --msgbox "\nyou need jq to do this.\ndid you read the README fool?" 10 50
    fi
    curl -s "https://api.github.com/licenses/$1" | jq -r '.body' >> $proj/LICENSE

    echo "## License\n" >> $proj/README.md
    echo "This project is licensed under the $1 license - see the [LICENSE](./LICENSE) for more details.\n" >> $proj/README.md
    echo "## Shoutouts\n" >> $proj/README.md
    echo "* props to ppl or code\n" >> $proj/README.md
}

cmd=(dialog --separate-output --checklist "Select a license:" 16 46 16)
options=(1 "MIT" off
         2 "LGPL-3.0" off
         3 "AGPL-3.0" off
         4 "Unlicense" off
         5 "Apache-2.0" off
         6 "GPL-3.0" off
         7 "Other" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        1 )
            get_license mit
            ;;
        2 )
            get_license lgpl-3.0
            ;;
        3 )
            get_license agpl-3.0
            ;;
        4 )
            get_license unlicense
            ;;

        5 ) get_license apache-2.0
            ;;

        6 ) get_license gpl-3.0
            ;;

        7 ) dialog --msgbox "\ncurrently, golf only grabs the licenses from the Github API(api.github.com/licenses).\n\nopen a PR if you want to show me a better way" 10 50
            ;;
    esac
done

##################
# github templates
##################
get_bug_report_template() {
    if [ ! -d $proj/.github ];
    then
        mkdir $proj/.github;
    fi
    
    URL="https://gist.githubusercontent.com/gretzky/5f856918cb7a91ba71a630625d061715/raw/cb61e5d71dd3377a9cf85925e08dc74e8a15a9d4/bug_report.md"
    curl "$URL" -o $proj/.github/BUG_REPORT.md >/dev/null 2>&1
}

get_feature_request_template() {
    if [ ! -d $proj/.github ];
    then
        mkdir $proj/.github;
    fi

    URL="https://gist.githubusercontent.com/gretzky/06fbb260bdbba18fd5d506b74e6e5bd9/raw/64b8bdf24fdb8b85d302f158b143b27b9466b466/feature_request.md"
    curl "$URL" -o $proj/.github/FEATURE_REQUEST.md >/dev/null 2>&1
}

get_pull_request_template() {
    if [ ! -d $proj/.github ];
    then
        mkdir $proj/.github;
    fi

    URL="https://gist.githubusercontent.com/gretzky/5db53d3a1921f54ffbe07042e7efc3cf/raw/2ac16f2cc8bf9555a9717033122099dcf4c0e6d4/pull_request.md"
    curl "$URL" -o $proj/.github/PULL_REQUEST_TEMPLATE.md >/dev/null 2>&1
}

generate_gh_templates() {
    dialog --title "bug report template" \
           --yesno "do you want a bug report template?" 10 50

    case $? in
        0 ) get_bug_report_template
            ;;
        1 ) :
            ;;
    esac

    dialog --title "feature request template" \
           --yesno "do you want a feature request template?" 10 50

    case $? in
        0 ) get_feature_request_template
            ;;
        1 ) :
            ;;
    esac

    dialog --title "pull request template" \
           --yesno "do you want a pull request template?" 10 50

    case $? in
        0 ) get_pull_request_template
            ;;
        1 ) :
            ;;
    esac
}

dialog --title "github templates" \
           --yesno "do you want to generate github templates? (for issues, pull requests, etc.)?" 10 50

    case $? in
        0 ) generate_gh_templates
            ;;
        1 ) :
            ;;
    esac

######
# done
######
dialog --title "golf" \
       --msgbox "\nall done!\nthanks for playing golf!" 10 50