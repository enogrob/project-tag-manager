#!/bin/bash
## Crafted (c) 2021 by Daitanlabs - We are stronger together
## Prepared : Roberto Nogueira
## File     : tag
## Project  : project-today-tags
## Reference: bash
## Depends  : project-today-manager,tree
## Purpose  : Provide a tag CLI to help to manage gtd process flow implemented in the file system.

# set -x

tag(){
case $1 in
  --version|-v|v|version)
    tag.version
    ;;
  --help|-h|h|help)
    printf "\e[1;37m%s \e[0m\n" "Crafted (c) 2022 by Daitanlabs - We are stronger together"
    tag.version
    tag.help 
    printf "\n"  
    printf "\e[0;32m%s \e[4m%s\e[0m\e[0m\n" "homepage" "http://bitbucket.wrs.com/users/rmartins/repos/project-tag-manager"
    printf "\n"
    ;;
  -l|list)
    shift
    tag.list $1 $2
    ;;
  -a|add)
    shift
    tag.add $1 $2
    ;;
  -r|remove)
    shift
    tag.remove $1 $2
    ;;
  -m|search)
    shift
    tag.mind $1
    ;;
esac
}
tag.add(){
  local tags=$1
  local project=$(if test -z $2 || test "$2" == "."; then echo $(basename $(pwd));else echo $2;fi)
  local project_name=(`grep "^$project\s" $TAGS_FILE | awk '{print $1}'`)
  local line
  if [ -z $project_name ]; then
    line=(`echo $tags | sed 's/,/ /g'`)
    line=($(echo "${line[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    line=`echo "${line[@]}" | sed 's/ /,/g'`
    echo -e "$project $line" >> $TAGS_FILE
  else
    line=(`grep "^$project\s" $TAGS_FILE | awk '{print $2}' | sed 's/,/ /g'`)
    line+=(`echo $tags | sed 's/,/ /g'`)
    line=($(echo "${line[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    line=`echo "${line[@]}" | sed 's/ /,/g'`
    sed -i "/^$project\s.*/c $project $line" $TAGS_FILE
  fi
}
tag.contains(){
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [[ ${!i} == "${value}" ]]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}
tag.help(){ printf "\e[1;37m%s\e[0m \e[1;36m%s\e[0m\n" "tag" "[$(tag.methods)]"; }
tag.list(){
  local project=$(if test -z $1 || test "$1" == "."; then echo $(basename $(pwd));else echo $1;fi)
  if test -d $TODAY_PROJECTS/$project; then
    grep "^$project\s" $TAGS_FILE | awk '{print $2}' 
  fi  
}
tag.methods(){ echo "-a|-h|-l[project|context]|-m|-r|-v"; }
tag.search(){
  local tags=(`echo $1 | sed 's/,/ /g'`)
  local projtags
  local projname
  while read line; do
    projtags=(`echo $line | awk '{print $2}' | sed 's/,/ /g'`)
    projname=(`echo $line | awk '{print $1}'`)
    for t in ${tags[@]}
    do
      if [ $(tag.contains "${projtags[@]}" "$t") == "y" ]; then
        echo "$projname"
      fi
    done
  done < $TAGS_FILE
}
tag.remove(){
  local tags=$1
  local project=$(if test -z $2 || test "$2" == "."; then echo $(basename $(pwd));else echo $2;fi)
  local tagsdel
  line=(`grep "^$project\s" $TAGS_FILE | awk '{print $2}' | sed 's/,/ /g'`)
  tagsdel=(`echo $tags | sed 's/,/ /g'`)
  for del in ${tagsdel[@]}
  do
    line=("${line[@]/$del}") #Quotes when working with strings
  done
  line=($(echo "${line[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
  line=`echo "${line[@]}" | sed 's/ /,/g'`
  sed -i "/^$project\s.*/c $project $line" $TAGS_FILE
}
tag.setup(){
  export TAG_UPDATE_MESSAGE="Initial version"
  export TAG_VERSION=v1.0.0
  export TAG_VERSION_DATE=2022.01.08

  export TAGS_FILE=$TODAY_PROJECTS/.tags

  shopt -s extglob

  TAGS_PROJECTS='+(aws|chrome|codewars|conf|coursera|ebook|edx|exercism|futurelearn|graphacademy|hackerrank|javabrains|job|krishnamurti|lab360|linkedin|linuxacademy|oreilly|phoenix|pragmaticstudio|project|rails|sololearn|specialization|windriver|tutorial|tutorialspoint|udemy|jetbrains|research)'
  TAGS_CONTEXTS='+(anki|bash|bigdata|bluemix|bootstrap|chartjs|cpp|css|debian|delphi|design|devops|docker|elixir|elm|erlang|grails|groovy|hadoop|html|java|javascript|jekyll|jquery|nodejs|neo4j|phoenix|puppet|python|r|rails|reactjs|roblox|rspec|ruby|scratch|spring|sinatra|springboot|sql|sveltejs|unix|vim|vuejs|webpack|youtube|stimulusreflex)'
  
  ! test -f $TAGS_FILE && touch $TAGS_FILE
}
tag.version(){
  printf "\e[0;37m%s \e[0m%s\n" "Tag" "$TAG_VERSION"
  printf "\n"
}

tag.setup