<p align="center"> <img src="https://user-images.githubusercontent.com/4303310/41114424-6d2d925c-6a95-11e8-9894-00f4a7037216.png" /></p>
    
</h1>
<p align="center" style="font-size: 1.2rem;"> Noddy Help DevOps in  macOS </p>
<hr />

| Command  | Description |:star: Now with plugins! You can check the plugins folder: [/noddy/plugins](https://github.com/anmolnagpal/noddy/tree/master/noddy/plugins)

_Contributions to add new plugins and keep improving the existing ones are welcome and very much appreciated!_

![image](https://github.com/anmolnagpal/noddy/raw/master/demo/demo.gif)

The ultimate tool for devops to manage their noddy. It provides a huge set of command line commands that automate the usage of your noddyOS system.
When you run a function, the executed command is displayed and that helps you memorize each of the Utilities for future usage.

---

### Installation in 1 Simple Step - Including configuration wizard!

Via curl
> `sh -c "$(curl -fsSL https://raw.githubusercontent.com/anmolnagpal/noddy/master/devops-noddy/tools/install)"`

Via wget
> `sh -c "$(wget https://raw.githubusercontent.com/anmolnagpal/noddy/master/devops-noddy/tools/install -O -)"`

Then, re-open your terminal client. You will be able to run all the commands listed below, for example:
> `noddy help`

---

### Configuration

The configuration is done when you install noddy CLI for the first time though the installer configuration wizard.
After that, you can update your noddy CLI configuration by editing the following file: `/usr/local/bin/noddy`

---

### Requirements

These are the requirements to be able to run all the commands (the dependencies/requirements are installed when you install noddy CLI for the first time):

* Homebrew
* Git
* Python
* Pipe Viewer (pv)

---

### Update

You can update noddy CLI to the latest version by running:
> `sh -c "$(curl -fsSL https://raw.githubusercontent.com/anmolnagpal/devops-noddy/master/noddy/tools/update)"`

---

### Uninstallation

You can uninstall noddy CLI by running:
> `sh -c "$(curl -fsSL https://raw.githubusercontent.com/anmolnagpal/devops-noddy/master/noddy/tools/uninstall)"`

---

### Integrated Projects

The following amazing projects have been integrated on the noddy script (all the integrated projects are optional and can be installed through the installation wizard):
* Glances (https://github.com/nicolargo/glances)
* MySQL CLI (https://github.com/dbcli/mycli)
* fast-cli (https://github.com/sindresorhus/fast-cli)
* iStats https://bjango.com/mac/istatmenus/

---

### Help / Commands List

| Command  | Description | Arguments |
| ------------- | ------------- | ------------- |
| `noddy help`  | List all available commands in noddy script  | |

### General Commands

| Command  | Description | Arguments |
| ------------- | ------------- | ------------- |
| `noddy update`  | Install noddyOS software updates, update installed Ruby gems, Homebrew, npm and their installed packages  | |
| `noddy lock`  | Lock  | |
| `noddy restart`  | Restart noddyOS  | |
| `noddy sleep`  | Sleep mode  | |
| `noddy shutdown`  | Shutdown  | |
| `noddy presentation`  | Prepare noddy for presentation: minimize all apps, close browsers, send files from desktop and downloads to trash and set not disturb mode  | |
| `noddy time`  | Show clock at top right position in Terminal/iTerm  | |
| `noddy screensaver`  | Start screensaver  | |
| `noddy folders:list`  | List folders in current directory with their current size  | |
| `noddy folder:size`  | Calculate current folder size  | |
| `noddy folders:remove-empty`  | Remove empty subdirectories  | |
| `noddy apps:close-all`  | Close all opened apps  | |
| `noddy bluetooth:status`  | Get the bluetooth status  | |
| `noddy bluetooth:enable`  | Enable bluetooth  | |
| `noddy bluetooth:disable`  | Disable bluetooth  | |
| `noddy wifi:status`  | Get the wifi status  | |
| `noddy wifi:scan`  | Scan available wifi networks  | |
| `noddy wifi:enable`  | Enable wifi  | |
| `noddy wifi:disable`  | Disable wifi  | |
| `noddy wifi:password`  | Get password for current wifi network  | |
| `noddy dock:add-space`  | Add blank space to dock  | |
| `noddy apps:app-store`  | Get list of installed apps from App Store  | |
| `noddy eject-all`  | Eject all mounted volumes and disks  | |
| `noddy battery`  | Get battery status  | |
| `noddy info`  | Get noddyOS version information  | |
| `noddy hidden:show`  | Show hidden files  | |
| `noddy hidden:hide`  | Hide hidden files  | |
| `noddy find:text X`  | Find exact phrase recursively inside directory  | X = Text string |
| `noddy find:biggest-files`  | Find biggest files inside directory  | |
| `noddy find:biggest-directories`  | Find biggest directories inside directory  | |
| `noddy zip:extract X` | Extract Zip file to current folder | X = Zip file to extract |
| `noddy gzip:compress X` | Compress current file using Gzip | X = File to compress |
| `noddy gzip:extract X` | Extract Gzip file to current folder | X = Gzip file to extract |
| `noddy tar:compress X`  | Compress X file/directory using tar with progress indicator  | X = File or directory |
| `noddy tar:extract X` | Extract tar file to current folder | X = Tar file to extract |


### Search Utilities

| Command  | Description | Arguments |
| ------------- | ------------- | ------------- |
| `noddy find:recent N`  | Find files modified in the last N minutes  |  N = number of minutes  |
| `noddy find:duplicated`  | Find duplicated files  |  |
| `noddy search:replace X` | Search and replace string in file | X = File to perform the search and replace operation |


### Network Utilities

| Command  | Description |
| ------------- | ------------- |
| `noddy speedtest`  | Internet connection speed test  |
| `noddy speedtest:infinite`  | Run internet speed test each 5 minutes  |
| `noddy ports`  | List of used ports  |
| `noddy ip:local`  | Get local IP address  |
| `noddy ip:public`  | Get public IP address  |


### SSH Utilities

| Command  | Description | Arguments |
| ------------- | ------------- | ------------- |
| `noddy ssh:download-file X`  | Download file from remote server through SSH  |  X = Path of the remote file to download  |
| `noddy ssh:download-folder X`  | Download entire folder from remote server through SSH  |  X = Path of the remote folder to download  |
| `noddy ssh:download-database X`  | Download MySQL from remote server through SSH  |  X = Name of the database to download  |
| `noddy ssh:sync:local X`  | Sync local folder with remote folder using rsync through SSH (download remote folder to local folder)  |  X = Path of the remote folder to sync to local folder  |
| `noddy ssh:sync:remote X`  | Sync remote folder with local folder using rsync through SSH (upload local folder to remote folder)  |  X = Path of the remote folder to sync from local folder  |
| `noddy ssh:upload X`  | Upload file to remote server through SSH  |  X = Path of the file to upload to the remote server  |
| `noddy ssh:public-key`  | Copy SSH Public Key  |  |
| `noddy ssh:list`  | List all the saved SSH credentials  |  |


### Performance and maintenance Utilities

| Command  | Description |
| ------------- | ------------- |
| `noddy system`  | Show system information to review mac performance  |
| `noddy temp`  | Show temperature, fan and battery statistics  |
| `noddy memory`  | See memory usage sorted by memory consumption  |
| `noddy trash:empty`  | Empty trash |
| `noddy trash:size`  | Calculate trash size |
| `noddy desktop:cleanup`  | Remove all files and directories from Desktop directory |
| `noddy downloads:cleanup`  | Remove all files and directories from Downloads directory |


### Git Utilities

| Command  | Description |
| ------------- | ------------- |
| `noddy git:config`  | Display local Git configuration  |
| `noddy git:open`  | Open current repository on Github  |
| `noddy git:create:branch`  | Create branch based on current branch  |
| `noddy git:branches:date`  | Get last update date for all branches in current project  |
| `noddy git:undo-commit`  | Undo latest commit  |
| `noddy git:log`  | See latest commits IDs and titles for current branch  |
| `noddy git:branch`  | See all branches  |
| `noddy git:branch:rename`  | Rename Git branch |
| `noddy git:branch:remove-local`  | Remove local Git branch |
| `noddy git:branch:remove-remote`  | Remove local and remote Git branch |
| `noddy git:remove`  | Remove Git from current project  |
| `noddy git:settings`  | Check Git settings  |
| `noddy git:add-removed`  | Add removed files to staged files  |
| `noddy git:size`  | Get size for current Git directory  |


### Homebrew Utilities

| Command  | Description |
| ------------- | ------------- |
| `noddy brew`  | Get a list of installed Homebrew packages  |


### Xcode Utilities

| ------------- | ------------- |
| `noddy xcode:cleanup`  | Cleanup Xcode files to free up hard disk space  |


### TODO

Add support for

- [ ] Docker 
- [ ] Ansible
- [ ] Terraform 

## 👬 Contribution

- Open pull request with improvements
- Discuss ideas in issues
- Reach out with any feedback [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/anmol_nagpal.svg?style=social&label=Follow%20%40anmol_nagpal)](https://twitter.com/anmol_nagpal)
