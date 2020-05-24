# prints the status of the desk into the prompt
function idasen_control_prompt_info() {
  IDASEN_PROMPT_TEMPLATE="$ZSH_THEME_IDASEN_PROMPT_TEMPLATE" idasen-control --prompt-fragment
}
