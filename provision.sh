#!/bin/bash


echo ">>>>> configuring pacman mirrors..."
sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sudo cp /vagrant/pacman.mirrorlist /etc/pacman.d/mirrorlist

echo ">>>>> adding infinality repo..."
cp /etc/pacman.conf .
printf '\n\n[%s]\nServer = %s' 'infinality-bundle' 'http://bohoomil.com/repo/$arch' >> pacman.conf
printf '\n\n[%s]\nServer = %s' 'infinality-bundle-fonts' 'http://bohoomil.com/repo/fonts' >> pacman.conf
printf '\n\n[%s]\nServer = %s' 'infinality-bundle-multilib' 'http://bohoomil.com/repo/multilib/$arch' >> pacman.conf
sudo mv pacman.conf /etc/pacman.conf

echo ">>>>> adding infinality repo key..."
cp /etc/pacman.d/gnupg/gpg.conf .
printf 'keyserver-options http-proxy = "http://web-proxy.oa.com:8080"' >> gpg.conf
sudo mv gpg.conf /etc/pacman.d/gnupg/gpg.conf
sudo pacman-key -r 962DDE58
sudo pacman-key --lsign-key 962DDE58

echo ">>>>> installing packages..."
sudo pacman -Syyu                  --noconfirm
sudo pacman -S git                 --noconfirm
sudo pacman -S zsh                 --noconfirm
sudo pacman -S gvim                --noconfirm
sudo pacman -S tmux                --noconfirm
sudo pacman -S meld                --noconfirm
sudo pacman -S emacs               --noconfirm
sudo pacman -S clang               --noconfirm
sudo pacman -S nodejs              --noconfirm
sudo pacman -S corkscrew           --noconfirm
sudo pacman -S qtcreator           --noconfirm
sudo pacman -S xorg-xauth          --noconfirm
sudo pacman -S xorg-xhost          --noconfirm
sudo pacman -S xorg-server         --noconfirm
sudo pacman -S the_silver_searcher --noconfirm

echo ">>>>> installing infinality bundle..."
sudo sh -c "yes y$'\n' | pacman -S cairo-infinality-ultimate"
sudo sh -c "yes y$'\n' | pacman -S freetype2-infinality-ultimate"
sudo sh -c "yes y$'\n' | pacman -S fontconfig-infinality-ultimate"
sudo pacman -S ttf-noto-fonts-ib          --noconfirm
sudo pacman -S ttf-noto-fonts-cjk-ib      --noconfirm
sudo pacman -S ttf-noto-fonts-emoji-ib    --noconfirm
sudo pacman -S ttf-noto-fonts-nonlatin-ib --noconfirm

echo ">>>>> installing pragmatapro font..."
prevdir=`pwd`
mkdir ~/tmp
cd ~/tmp
curl -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/ttf-pragmatapro.tar.gz
tar xzvf ttf-pragmatapro.tar.gz
cd ttf-pragmatapro
mkdir src
cp /vagrant/PragmataPro0821/PragmataProB_0821.ttf src/
cp /vagrant/PragmataPro0821/PragmataProI_0821.ttf src/
cp /vagrant/PragmataPro0821/PragmataProR_0821.ttf src/
cp /vagrant/PragmataPro0821/PragmataProZ_0821.ttf src/
cp /vagrant/PragmataPro0821/PragmataPro_Mono_B_0821.ttf src/
cp /vagrant/PragmataPro0821/PragmataPro_Mono_I_0821.ttf src/
cp /vagrant/PragmataPro0821/PragmataPro_Mono_R_0821.ttf src/
cp /vagrant/PragmataPro0821/PragmataPro_Mono_Z_0821.ttf src/
makepkg -sri --noconfirm
cd $prevdir
rm -rf ~/tmp

echo ">>>>> changing default shell to zsh..."
rm ~/.bash*
sudo chsh -s /usr/bin/zsh vagrant

echo ">>>>> changing ssh config to allow X11 forwarding..."
awk '{gsub(/^#X11Forwarding no/, "X11Forwarding yes"); gsub(/^#AllowTcpForwarding/, "AllowTcpForwarding"); gsub(/^#X11UseLocalhost/, "X11UseLocalhost"); gsub(/^#X11DisplayOffset/, "X11DisplayOffset"); print}' /etc/ssh/sshd_config > tmp
diff tmp /etc/ssh/sshd_config
sudo mv tmp /etc/ssh/sshd_config
sudo systemctl restart sshd.service

echo ">>>>> configuring environments..."
prevdir=`pwd`
cd ~
git clone https://github.com/kelvinh/dotfiles.git .config
cd ~/.config/zsh
git clone https://github.com/robbyrussell/oh-my-zsh.git
cd ~/.config/emacs
git clone https://github.com/syl20bnr/spacemacs.git emacs.d
cd ~
ln -s .config/alsa/asoundrc .asoundrc
ln -s .config/emacs/emacs.d .emacs.d
ln -s .config/emacs/spacemacs .spacemacs
ln -s .config/tmux/tmux.conf .tmux.conf
ln -s .config/xorg/xinitrc .xinitrc
ln -s .config/zsh/zprofile .zprofile
ln -s .config/zsh/zshrc .zshrc
ln -s .config/git/gitconfig .gitconfig
cd $prevdir

echo ">>>>> configuring ssh..."
echo "ProxyCommand corkscrew web-proxy.oa.com 8080 %h %p" > ~/.ssh/config
cp /vagrant/id_rsa ~/.ssh
chmod 600 ~/.ssh/id_rsa
