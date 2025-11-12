# Assignment Setup Installation Guide

## VM

You will complete the assignments inside a VM. This section guides you
through the steps that are necessary to set up a VM for the assignments.

You can also run this on a bare-metal system if you prefer, but we
recommend using a VM for simplicity.

We will not provide guidance if you run into problems when installing
the VM.

1.  Use a virtualization software, such as VirtualBox
    (<https://www.virtualbox.org/>) to install the **Ubuntu 24.04.3**
    ISO.

    For `x86`, you can use the following download
    link:\
    <https://ubuntu.com/download/desktop/thank-you?version=24.04.3&architecture=amd64&lts=true>\
    For `ARM` (e.g., Mac with M\* CPU), you can download
    the ARM ISO from
    <https://cdimage.ubuntu.com/noble/daily-live/current/> via this
    download link:
    <https://cdimage.ubuntu.com/noble/daily-live/current/noble-desktop-arm64.iso>

3.  In the VM, open a terminal `(CTRL+ALT+T)`, and use the commands below.

    ``` bash
    sudo apt update && sudo apt upgrade  
    sudo apt install build-essential curl wget \
        git vim python3-venv python3-pip
    ```

## Mininet and P4

1.  We will now install P4, which is required for the second assignment.
    The P4 installation script automatically installs all dependencies,
    including mininet, which is used in the first assignment. Note that
    this installation process may take several hours.

    ``` bash
    git clone https://github.com/jafingerhut/p4-guide.git
    cd p4-guide/bin
    ./install-p4dev-v9.sh                                          
    ```

    The installation script will create a virtual environment with the necessary toolset.
    After it has been installed, we can activate a virtual environment
    (venv) to run our P4-related programs. If you want to install
    packages for your project through `pip install`, do it in the
    virtual environment. You can use `deactivate` to exit the venv.

    ``` bash
    source ~/p4-guide/bin/p4dev-python-venv/bin/activate
    cd ~ 
    ```

    To verify that P4 has been successfully installed, run the basic forwarding example from the tutorials folder within the P4 virtual environment.
    If everything works correctly, you should end up with mininet running. Exit mininet using `CTRL+D` or `exit`.

    ``` bash
    cd ~/p4-guide/bin/tutorials/exercises/basic
    make run
    ```

## Ryu

In the first exercise, we will use Ryu to set up SDN controllers. Ryu
does not work with Python 3.12. So, we will set up a virtual environment
in which we will run Python 3.9.19.

1.  We will start by installing the required dependencies.

    ``` bash
    sudo apt -y install build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev libffi-dev \
        liblzma-dev tk-dev uuid-dev libncurses5-dev \ 
        libncursesw5-dev ca-certificates pkg-config
    ```

2.  Now we will install and configure `pyenv`, and install Python
    3.9.19.

    ``` bash
    curl -fsSL https://pyenv.run | bash
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo '[[ -d $PYENV_ROOT/bin ]] \
        && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init - bash)"' >> ~/.bashrc
    exec bash
    pyenv --version
    ```

    If everything worked, `pyenv –version` should show `pyenv 2.6.12`,
    then we can install Python 3.9.19.

    ``` bash
    pyenv install 3.9.19
    ```

3.  Now we are going to clone and prepare the Ryu installation.

    ``` bash
    mkdir -p ~/sdn && cd ~/sdn
    git clone https://github.com/faucetsdn/ryu.git
    cd ryu
    pyenv local 3.9.19
    python -m venv ryu3.9
    source ryu3.9/bin/activate
    python --version
    ```

    `python –version` should now show Python 3.9.19. If it does not show
    3.9.19, but instead shows 3.12.3, something likely went wrong with
    the pyenv configuration. Use the following commands:

    ``` bash
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    cd ~/sdn/ryu
    rm -rf ryu3.9
    python -m venv ryu3.9
    source ryu3.9/bin/activate
    python3 --version
    ```

4.  Now we need to install the correct version of our tools and
    dependencies, and install ryu.

    ``` bash
    pip install --upgrade 'pip<24' wheel
    pip install 'setuptools==67.6.1'
    pip install 'eventlet==0.31.1' 'greenlet<2.0'
    pip install . --no-build-isolation
    ```
5. Install `mininet` system-wide using the following command:
   
    ```bash
    sudo apt-get install mininet
    ```



1.  We can now check if ryu is installed by running a simple program. Without mininet running this doesn't do anything and wil get stuck on initialising, but as long as you don't get any Python errors, the installation worked.

    ``` bash
    ./bin/ryu-manager ./ryu/app/simple_switch_13.py
    ```

    **Note:** Ryu must run with Python 3.9.19 (via pyenv). Keep system
    Python 3.12.3 for other tools such as P4-related frameworks. Running
    `python3 –-version` allows you to check your Python version.

    We have now installed everything we need to do all of the

    assignments. Have fun!
