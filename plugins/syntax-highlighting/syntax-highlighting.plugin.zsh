#
# External
#

[[ -d $ZEPHYRDIR/contribs/zsh-syntax-highlighting ]] || _zephyr_clone zsh-users/zsh-syntax-highlighting
source $ZEPHYRDIR/contribs/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

#
# Highlighting
#

# Set highlighters
zstyle -a ':zephyr:plugin:syntax-highlighting' highlighters 'ZSH_HIGHLIGHT_HIGHLIGHTERS'
if (( ${#ZSH_HIGHLIGHT_HIGHLIGHTERS[@]} == 0 )); then
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
fi

# Set highlighting styles
typeset -A syntax_highlighting_styles
zstyle -a ':zephyr:plugin:syntax-highlighting' styles 'syntax_highlighting_styles'
for syntax_highlighting_style in "${(k)syntax_highlighting_styles[@]}"; do
  ZSH_HIGHLIGHT_STYLES[$syntax_highlighting_style]="$syntax_highlighting_styles[$syntax_highlighting_style]"
done
unset syntax_highlighting_style{s,}

# Set pattern highlighting styles
typeset -A syntax_pattern_styles
zstyle -a ':zephyr:plugin:syntax-highlighting' pattern 'syntax_pattern_styles'
for syntax_pattern_style in "${(k)syntax_pattern_styles[@]}"; do
  ZSH_HIGHLIGHT_PATTERNS[$syntax_pattern_style]="$syntax_pattern_styles[$syntax_pattern_style]"
done
unset syntax_pattern_style{s,}
