# setup.sh
#!/bin/bash

# Create symbolic links
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/nvim ~/.config/nvim

echo "Configuration files have been linked."
