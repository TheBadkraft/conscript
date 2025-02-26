**How to Use:**  
1. Navigate to the `./tools/sigtest/` directory.  

2. Make the script executable:

``` bash
chmod +x install_sigtest.sh
```

3. Run the script with root permissions:

``` bash
sudo ./install.sh
```

**What It Does:**  
- Checks if the script is run from the correct directory (./tools/sigtest/).  
- Ensures the script is run with root permissions (required for copying files to /usr/lib and /usr/include).  
- Copies `libsigtest.so` to /usr/lib/.  
- Copies `sigtest.h to` /usr/include/.  
- Provides feedback on success or failure for each step.  
