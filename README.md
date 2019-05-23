# LXD_GPU_SERVER
实验室GPU服务器的LXD虚拟化
实验室GPU服务器的LXD虚拟化 实验室破天荒加了台GPU服务器，因为实验室人数比较多，如果用同一台，文件、环境、软件等错乱混杂，有强迫症。。。所以我们做了虚拟化。

##第一步：宿主机的安装与配置	
服务器系统的安装（建议安装server版，通过ssh远程）服务器显卡驱动的安装 https://medium.com/@cjanze/how-to-install-tensorflow-with-gpu-support-on-ubuntu-18-04-lts-with-cuda-10-nvidia-gpu-312a693744b5

## 第二步：lxd安装
### 安装lxd
分别安装LXD， ZFS和bridge-utils
LXD 实现虚拟容器
ZFS 用于管理物理磁盘，支持LXD高级功能
bridge-utils 用于搭建网桥
sudo apt-get install lxd zfsutils-linux bridge-utils
### 配置网桥:
因为学校信息中心网络问题，如果配置桥接网卡，会导致流量异常，直接断网，因此实现每人一个ip的方式失败，不得已我们采用端口转发的方式来实现各个容器的网络
### 配置ZFS
首先，我们运行sudo fdisk -l列出服务器上的可用磁盘和分区，我们有两块硬盘，第一块为系统盘，第二块为数据盘，现在我们将数据盘（/dev/sdb）分出需要使用的空间，作为容器的存储卷。
sudo fdisk /dev/sdb
