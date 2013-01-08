pysharepath=/usr/local/share/python

if [[ -x $pysharepath ]]; then
  export PATH="$pysharepath:$PATH"
fi

unset pysharepath
