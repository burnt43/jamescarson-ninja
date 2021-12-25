#!/bin/bash

function echo_error {
  local msg="$1"
  echo -e "[\033[0;31mERROR\033[0;0m] - $msg"
}

function echo_proc {
  local msg="$1"
  echo -n "$msg..."
}

function echo_ok {
  echo -e "\033[0;32mOK\033[0;0m"
}

function echo_fail {
  echo -e "\033[0;31mFAIL\033[0;0m"
}

script_dir=$(dirname $0)
path_to_create="$1"
file_to_create="$2"

if [[ ! -z "$path_to_create" ]]; then
  # This is the relative url for the files we are creating. They should be
  # accessible from the webserver.
  relative_url_path="/css_secrets/${path_to_create}"
  path_to_create="${script_dir}/${path_to_create}"

  # Try and create the path.
  echo_proc "mkdir -p $path_to_create"
  mkdir -p $path_to_create
  ([[ "$?" == "0" ]] && echo_ok) || echo_fail

  # If there is a file to create, then create it.
  if [[ ! -z "$file_to_create" ]]; then
    # Ensure the css file exists.
    css_file_to_create="${path_to_create}/${file_to_create}.css"
    echo_proc "touch $css_file_to_create"
    touch $css_file_to_create
    ([[ "$?" == "0" ]] && echo_ok) || echo_fail

    # Ensure the html files exists.
    html_file_to_create="${path_to_create}/${file_to_create}.html"
    echo_proc "touch $html_file_to_create"
    touch $html_file_to_create
    ([[ "$?" == "0" ]] && echo_ok) || echo_fail

    # Write the basic skeleton html that will include the associated css file.
    echo_proc "writing default html in $html_file_to_create"
    cat > $html_file_to_create <<-EOF
<html>
  <head>
    <link rel="stylesheet" href="${relative_url_path}/${file_to_create}.css">
  </head>
  <body>
    <h1>Change This</h1>
  </body>
</html>
EOF
    ([[ "$?" == "0" ]] && echo_ok) || echo_fail
  fi

  # Ensure the index file exists.
  index_file_to_create="${path_to_create}/index.html"
  echo_proc "touch $index_file_to_create"
  touch $index_file_to_create
  ([[ "$?" == "0" ]] && echo_ok) || echo_fail

  # Update the index page to include all the subpages.
  list=""
  for file in $(find $path_to_create -type f -name "*.html" ! -name "index.html" | sort); do
    name=$(basename "$file" | cut -d. -f1)
    list="${list}<li><a href=\"${relative_url_path}/${name}.html\">${name}</a></li>"
  done

  echo_proc "writing default index for $relative_url_path in $index_file_to_create"
  cat > $index_file_to_create <<-EOF
<html>
<head>
</head>
<body>
<ul>
${list}
</ul>
</body>
</html>
EOF
  ([[ "$?" == "0" ]] && echo_ok) || echo_fail
fi

list=""
for dir in $(find $script_dir -type d ! -name "." ! -name "img" | sort); do
  name=$(basename "$dir")
  list="${list}<li><a href=\"/css_secrets/${name}\">${name}</a></li>"
done

# Update the root index to include all the subdirs.
echo_proc "writing root index"
cat > "${script_dir}/index.html" <<-EOF
<html>
<head>
</head>
<body>
<ul>
${list}
</ul>
</body>
</html>
EOF
([[ "$?" == "0" ]] && echo_ok) || echo_fail
