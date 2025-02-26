#!/bin/bash

# Add a help switch (-h)
if [[ "$1" == "-h" ]]; then
  echo "Usage: $0"
  echo "Installs cproj.sh to ~/bin and ensures ~/bin is in your PATH."
  exit 0
fi

# Ensure ~/bin exists
if [ ! -d ~/bin ]; then
  echo "Creating ~/bin directory..."
  mkdir -p ~/bin
fi

# Ensure ~/bin is in the PATH
if ! echo $PATH | grep -q ~/bin; then
  echo "Adding ~/bin to your PATH in ~/.bashrc..."
  echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
  source ~/.bashrc
fi

# Copy cpp_proj.sh to ~/bin
if [ -f cproj.sh ]; then
  echo "Copying cproj.sh to ~/bin..."
  cp cproj.sh ~/bin/cproj
  chmod +x ~/bin/cproj
  cp ctemplates.sh ~/bin/ctemplates.sh
  echo "Installation complete! You can now use 'cproj' from anywhere."
else
  echo "Error: cproj.sh not found in the current directory."
  exit 1
fi
