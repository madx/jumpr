#!/bin/bash

# Add this somewhere in your bashrc or bash_completion.d

_j_complete() {
  local cur prev opts marks deleters jumprc
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="--list --help"

  jumprc="$HOME/.jumprc"
  marks=""
  deleters=""

  for file in $(grep : ${jumprc} | cut -d: -f1 | xargs echo -n); do
    marks="${marks} $file"
    deleters="${deleters} -@$file"
  done

  case "${cur}" in
    -@*)
      COMPREPLY=( $(compgen -W "${deleters}" -- ${cur}) )
      return 0
      ;;
    -*)
      COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
      return 0
      ;;
    *)
      COMPREPLY=( $(compgen -W "${marks} ${opts} ${deleters}" -- ${cur}) )
      return 0
      ;;
  esac

  if [[ ${prev} == @* ]]; then
    COMPREPLY=( $(compgen -f ${cur}) )
    return 0
  fi

}

complete -o nospace -F _j_complete j
