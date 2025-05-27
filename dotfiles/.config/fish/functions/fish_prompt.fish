function fish_prompt
  set -l last_status $status
  set -l stat
  if test $last_status -ne 0
    set stat (set_color red)"[$last_status]"(set_color normal)
  end
  string join '' -- (set_color blue) $USER ': ' (set_color green) (prompt_pwd --full-length-dirs 2) (set_color normal) $stat ' > '
end
