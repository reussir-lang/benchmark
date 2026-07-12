#!@runtimeShell@

output="$(@llvmConfig@ "$@")" || exit $?
printf '%s\n' "$output" | sed \
  -e "s|@llvmDev@|$(dirname "$(dirname "$0")")|g" \
  -e "s|@llvmLib@|$(dirname "$(dirname "$0")")|g" \
  -e "s|@llvmOut@|$(dirname "$(dirname "$0")")|g"
