# Show the version of rust that is active for the given cargo project.  This is
# useful if multirust is enabled.
function multirust_prompt_info() {
  if $(cargo read-manifest > /dev/null 2>&1); then
    echo "${ZSH_THEME_MULTIRUST_PREFIX}$(rustc --version | cut -d' ' -f2)${ZSH_THEME_MULTIRUST_SUFFIX}"
  fi
}
