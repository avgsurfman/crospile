export ROS_DISTRO=iron

export TOOLS=/usr
#again, make it extendible by changing the value with dpkg -L 

cross-colcon-build() {
    if [ ! "$(ls -A /home/develop/rootfs/)" ]; then
        echo "WARNING: Your rootfs directory is empty!"
        echo "    Please mount rootfs using e.g. 'sshfs -o follow_symlinks,allow_other -o cache_timeout=115200 pi@[raspberry_pi_ip]:/ /home/develop/rootfs'"
        echo "    or synchronize it with e.g. 'rsync -rLR --safe-links pi@[raspberry_pi_ip]:/{lib,usr,opt/vc/lib} /home/develop/rootfs'"
        echo "    Otherwise, the empty rootfs directory may cause your build to fail!"
        echo ""
    fi

    USERPATH=/home/develop/rootfs
    #extendible in the future

    export C_INCLUDE_PATH="\
	    ${USERPATH}/usr/include:\
	    ${USERPATH}/usr/include/arm-linux-gnueabihf:\
	    ${USERPATH}/usr/include/aarch64-linux-gnu"
    export CPLUS_INCLUDE_PATH="\
	    ${USERPATH}/usr/include:\
	    ${USERPATH}/usr/include/arm-linux-gnueabihf:\
	    ${USERPATH}/usr/include/aarch64-linux-gnu"

    colcon build \
        $@ \
        --merge-install \
        --cmake-force-configure \
        --cmake-args \
	--compile-no-warning-as-error\
        -DCMAKE_TOOLCHAIN_FILE=/home/develop/toolchain.cmake \
        -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
        -DTHIRDPARTY=ON \
        -DBUILD_TESTING:BOOL=OFF \ 
	-DRUN_HAVE_STD_REGEX=1
    	
}

cross-initialize() {
    mkdir -p /home/develop/ros2_ws/src
    cd /home/develop/ros2_ws
    wget https://raw.githubusercontent.com/ros2/ros2/${ROS_DISTRO}/ros2.repos
    vcs import /home/develop/ros2_ws/src < ros2.repos
}

cross-generator() {
    export ROS_PACKAGE_PATH=/home/develop/ros2_ws/src
    rosinstall_generator $1 --deps --exclude RPP --rosdistro ${ROS_DISTRO} > /tmp/rospkgs.repos
    vcs import ${ROS_PACKAGE_PATH} < /tmp/rospkgs.repos
}
