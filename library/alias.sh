unalias -a

alias sb="source ~/.bashrc"
alias eg="vim ${DOTFILE_PATH}/configs/.gitconfig"
alias ea="vim ${DOTFILE_PATH}/library/alias.sh"
alias ef="vim ${DOTFILE_PATH}/library/functions.sh"
alias ev="vim ${DOTFILE_PATH}/configs/.vimrc"
alias et="vim ${DOTFILE_PATH}/configs/.tmux.conf"
alias em="vim ${DOTFILE_PATH}/machine/$(dotfiles::utils::hostname).sh"
alias eu="vim ~/.bashrc.user"

# alias ssh="dotfiles::user::ssh"

alias miniforge3="dotfiles::user::miniforge3"

alias df-install="dotfiles::bashrc::append && source ${HOME}/.bashrc"
alias df-uninstall="dotfiles::bashrc::remove && dotfiles::uninstall && source ${HOME}/.bashrc"

# https://musigma.blog/2021/05/09/gpg-ssh-ed25519.html
# https://benjamintoll.com/2023/09/06/on-creating-a-signing-subkey/
# https://markentier.tech/posts/2021/02/github-with-multiple-profiles-gpg-ssh-keys/
# https://insight.o-o.studio/article/setting-up-gpg.html
alias gpg-quick="dotfiles::user::gpg::quick"
alias gpg-list="dotfiles::user::gpg::list"
alias gpg-quick-add="dotfiles::user::gpg::quick-add"
alias gpg-gen-revoke="dotfiles::user::gpg::gen-revoke"
alias gpg-clean="dotfiles::user::gpg::clean"
alias gpg-export="dotfiles::user::gpg::export"
alias gpg-import="dotfiles::user::gpg::import"

alias ssh-pass="ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no"
alias ssh-new="dotfiles::user::ssh::new"
