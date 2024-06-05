# cROSpile

c**ROS**pile is a simple script for cross-compiling ROS2 packages from scratch, inspired by [this repo]()


## About cROSpile

With the deprecation of the official ROS2 tool and abbadonment of support for cross-compilation of ROS2,
there is no recent native script for cross-compilation of recent ROS versions, especially for Raspberry Pi 4 and above.

This script compiles ROS2 packages for Debian Bookworm. You can quickly adapt it for different architectures as needed — all you need to
chane is the CMAKE optimization flags in the `toolchain.cmake` file and provide a compiler source.

> [!NOTE]
> This script is fairly plain and needs a lot of love. The script was planned to be automated with ssh as to
> provide automatic mounting of directories, but due to problems that I ran into with rsync, I was unable to automate it.
> Only the --offline mode works.


## Usage

```
./cROSpile --offline --arch=xyz --url=abc
```
, where:

+ --offline  Specifies that the script will run without ssh (necessary)
+ (Optional) The architecture (The user will be prompted otherwise)
+ (Optional) Toolchain `tar.xz` to be downloaded and installed.


> [!WARNING]
> If you are using anything else than aarch64 or arm, please change the toolchain's file optimization flags. 
> Alternatively, you can submit a commit if you find a clean way to automate this.

## Installation

```
git clone https://github.com/avgsurfman/crospile
```
Change the directory and execute the file.

## ⚖️ License
This code is licensed under [Apache v2 License](LICENSE-Apache) as well as [3-clause BSD license](LICENSE-BSD). 



