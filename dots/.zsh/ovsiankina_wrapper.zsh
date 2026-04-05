function ov()
( # subshell for local functions
	print_usage() {
	    echo "Wrapper for my scripts"
	    echo " "
	    echo "Usage:"
	    echo " "
	    echo "-h, --help                show brief help"
	    echo "-t, --test                test the wrapper"
	    exit 0
	}
	
	test_wrapper() {
		echo "Wrapper tested"
	}

	if [ $# -eq 0 ]; then
		echo "Error: A flag is required." >&2
		print_usage
	fi

	for arg in "$@"; do
	  shift
	  case "$arg" in
	    "--help") set -- "$@" "-h" ;;
	    "--test") set -- "$@" "-t" ;;
	    *) set -- "$@" "$arg" ;;
	  esac
	done
	
	while getopts 'tvh' flag; do
	  case "${flag}" in
	    t) test_wrapper ;;
	    h) print_usage ;;
	    *) print_usage ;;
	  esac
	done
)
