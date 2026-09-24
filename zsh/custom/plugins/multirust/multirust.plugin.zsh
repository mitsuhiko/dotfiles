# Show the version of rust that is active for the given cargo project.  This is
# useful if multirust is enabled.
function multirust_prompt_info() {
  # Cheap check for a Cargo.toml in this or a parent directory before
  # spawning cargo (which costs ~20ms even outside of rust projects).
  local dir=$PWD
  while [[ ! -f $dir/Cargo.toml ]]; do
    [[ $dir == / ]] && return
    dir=${dir:h}
  done
  if cargo verify-project > /dev/null 2>&1; then
    local v=$(rustc --version)
    echo "${ZSH_THEME_MULTIRUST_PREFIX}${${(s: :)v}[2]}${ZSH_THEME_MULTIRUST_SUFFIX}"
  fi
}
