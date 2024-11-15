#/usr/bin/env bash

# general
sitename="postprose"
baseurl="https://postprose.net"
lang="en"
datedfolders=true

# color theme
background_color="#f6f7fc"
text_color="#343636"
link_color="#006edc"
quote_color="#f6d6d9"

render_template(){
local title=$1
local content=$2

local html="<!DOCTYPE html>
<html lang=\"${lang:=en}\">
<head>
<meta charset=\"utf-8\">
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
<title>$title</title>
</head>
<body>
<main>
$content
</main>
<footer>
</footer>
</html>
"

printf "%s\n" "$html"
}

wrap_index_content(){
local content=$1

local index_content="

<h1>$sitename</h1>
<ul>
$content
</ul>
"
printf "%s\n" "$index_content"
}

usage() {
  printf "usage: $0 SRC_DIR DST_DIR\n"
  exit 1
}

[[ -d $1 ]] && source_dir=$1 || usage
[[ ! -z $2 ]] && dest_dir=$2 || usage

# remove trailing slash from baseurl
baseurl=${baseurl%/}

posts_dir="$dest_dir/posts"
posts_url="$baseurl/posts"

mkdir -p $posts_dir

mdfiles=($source_dir/*.md)
for ((i=${#mdfiles[@]}-1;i>=0;i--)); do
  filename="${mdfiles[$i]##*/}"
  read -r pubdate name ext <<< ${filename//./ }
  post=$(markdown $source_dir/$filename)
  [[ $post =~ \<h1\>(.*)\</h1\> ]] && post_title=${BASH_REMATCH[1]}
  echo $filename
  #Check to see whether we should create dated folders and nest the posts
  if [[ "$datedfolders" == "true" ]]; then
  mkdir $posts_dir/${filename:0:10}
  strippedfilename=${filename#*.}
  cleanfilename=${strippedfilename%.*}
  datefolder=${filename:0:10}
  render_template "$post_title" "$post" > $posts_dir/${datefolder}/${cleanfilename}.html
  else
  render_template "$post_title" "$post" > $posts_dir/${filename%%.md}.html
  fi

  # generate posts list for index
  posts_list+="
  <li style="list-style-type="none"">
  <a href=\"$posts_url/$datefolder/${cleanfilename}.html\">$post_title</a>
  -
  $pubdate
  </li>
  "
done

index_content=$(wrap_index_content "$posts_list")
render_template "$sitename" "$index_content" > $dest_dir/index.html
