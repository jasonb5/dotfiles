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

alias dotfile-install="dotfiles::bashrc::append && source ${HOME}/.bashrc"
alias dotfile-uninstall="dotfiles::bashrc::remove && dotfiles::uninstall && source ${HOME}/.bashrc"

# https://musigma.blog/2021/05/09/gpg-ssh-ed25519.html
# https://benjamintoll.com/2023/09/06/on-creating-a-signing-subkey/
# https://markentier.tech/posts/2021/02/github-with-multiple-profiles-gpg-ssh-keys/
alias gpg-newkey="gpg --full-generate-key --expert"
alias gpg-fingerprints="gpg --fingerprint --with-colons | grep fpr"
alias gpg-newsign="gpg --quick-add-key $KEYFP ed25519 sign 1y"
alias gpg-newencr="gpg --quick-add-key $KEYFP cv25519 encr 1y"
alias gpg-newauth="gpg --quick-add-key $KEYFP ed25519 auth 1y"
alias gpg-ls="gpg -K"
alias gpg-ls-keygrip="gpg --with-keygrip --list-key"
alias gpg-ls-secret="gpg --list-secret-keys --keyid-format SHORT"
alias gpg-ls-secret-long="gpg --list-secret-keys --keyid-format LONG"

alias ssh-new="ssh-keygen -t ed25519 -C $1"
