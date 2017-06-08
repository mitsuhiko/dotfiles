function transportstatus_prompt_info() {
  PLANE_TEMPLATE="$ZSH_THEME_PLANEINFO_TEMPLATE" TRAIN_TEMPLATE="$ZSH_THEME_TRAININFO_TEMPLATE" python "$ZSH_CUSTOM/plugins/transportstatus/transportstatus.py"
}
