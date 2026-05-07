# Set shell options
set_opts=(
  AUTO_CD NO_BEEP MAGIC_EQUAL_SUBST LIST_PACKED PROMPT_SUBST
  EXTENDED_GLOB GLOB_DOTS NUMERIC_GLOB_SORT NULL_GLOB
)
for opt in "${set_opts[@]}"; do
  setopt "$opt"
done
unset opt set_opts
