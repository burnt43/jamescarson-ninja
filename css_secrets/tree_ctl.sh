#!/bin/bash

# --------------------------------------------------------------------------------
# Define Functions
# --------------------------------------------------------------------------------
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

# --------------------------------------------------------------------------------
# Handle Args
# --------------------------------------------------------------------------------
script_dir=$(dirname $0)
subdirectory="$1"
leaf_file="$2"

if [[ ! -z "$subdirectory" ]]; then
  # This is the relative url for the files we are creating. They should be
  # accessible from the webserver.
  relative_url_path="/css_secrets/${subdirectory}"
  subdirectory="${script_dir}/${subdirectory}"

  # Try and create the path.
  echo_proc "mkdir -p $subdirectory"
  mkdir -p $subdirectory
  ([[ "$?" == "0" ]] && echo_ok) || echo_fail

  # --------------------------------------------------------------------------------
  # Write HTML & CSS File
  # --------------------------------------------------------------------------------
  if [[ ! -z "$leaf_file" ]]; then
    # Ensure the css file exists.
    css_file_to_create="${subdirectory}/${leaf_file}.css"
    echo_proc "touch $css_file_to_create"
    touch $css_file_to_create
    ([[ "$?" == "0" ]] && echo_ok) || echo_fail

    # Ensure the html files exists.
    html_file_to_create="${subdirectory}/${leaf_file}.html"
    echo_proc "touch $html_file_to_create"
    touch $html_file_to_create
    ([[ "$?" == "0" ]] && echo_ok) || echo_fail

    # Write the basic skeleton html that will include the associated css file.
    echo_proc "writing default html in $html_file_to_create"
    cat > $html_file_to_create <<-EOF
<html>
  <head>
    <link rel="stylesheet" href="${relative_url_path}/${leaf_file}.css">
  </head>
  <body>
    <h1>Change This</h1>
  </body>
</html>
EOF
    ([[ "$?" == "0" ]] && echo_ok) || echo_fail
  fi

  # --------------------------------------------------------------------------------
  # Write Subdir Index
  # --------------------------------------------------------------------------------

  index_file_to_create="${subdirectory}/index.html"
  echo_proc "touch $index_file_to_create"
  touch $index_file_to_create
  ([[ "$?" == "0" ]] && echo_ok) || echo_fail

  list=""
  for file in $(find $subdirectory -type f -name "*.html" ! -name "index.html" | sort); do
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

# --------------------------------------------------------------------------------
# Write Root Index
# --------------------------------------------------------------------------------

list=""
for dir in $(find $script_dir -type d ! -name "." ! -name "img" | sort); do
  name=$(basename "$dir")
  list="${list}<li><a href=\"/css_secrets/${name}\">${name}</a></li>"
done

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
