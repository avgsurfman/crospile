#!/usr/bin/env python3

import sys
import subprocess
import json
import logging
import argparse
from pathlib import Path


TARGET_ARCH = ""
OFFLINE = False
URL = ""

"""
str: global variable for target architecture

This sucks and I cannot justify having it global.
"""


def parse_opts():
    """
    Parses options and arguments.
    """
    parser = argparse.ArgumentParser(prog="cROSpile", description="Script for\
            automatic cross-compilation of ROS2.")
    parser.add_argument("--url", type=str, help="(Optional)The URL of the\
            Toolchain", metavar="URL", action="store", required=False)
    parser.add_argument("-f", "--offline", help="Execute the script offline\
            (without ssh to sync the libraries)", action="store_true")
    # silent / verbose
    parser.add_argument("-v", "--verbose", help="Verbose output and\
            Debug info", action="store_true", dest="verbose")
    parser.add_argument("-a", "--arch", help="Specify architecture manually",
                        action="store", required=False)
    args = parser.parse_args(sys.argv[1:])
    # (args)
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)
        logging.debug("Debug active.")
    else:
        logging.basicConfig(level=logging.INFO)
    global OFFLINE
    if args.offline:
        OFFLINE = True
        print("Starting in offline mode...")
    else:
        OFFLINE = False
    if args.arch:
        global TARGET_ARCH
        TARGET_ARCH = args.arch
    if args.url:
        global URL
        URL = args.url
        logging.debug(f"URL is now {URL}")


def get_arch(ps=subprocess.Popen(["lscpu", "-J"],
                                 stdout=subprocess.PIPE, text=True),
             return_dict=False):
    """
    Returns either a string or dict based on supplied bool kwarg.

    Requires a process ps, with stdout for input to the main command.
    """
    # "lscpu -J | jq '.lscpu | map( { (.field): .data } ) | add'"
    cmd = ["jq '.lscpu | map( { (.field): .data } ) | add'"]
    result = subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stdin=ps.stdout,
            shell=True, text=True)
    output, error = result.communicate()
    logging.debug(f"Output:{output}")
    try:
        lscpu = json.loads(output)
        if return_dict:
            return lscpu
        return lscpu['Architecture:']
    except json.JSONDecodeError as err:
        logging.error(f"Error while parsing the string. \n {err}")


def get_host_arch():
    """
    Macro for returning host lscpu.
    """
    return get_arch()


def start_docker(target_arch: str, url=""):
    """
    Creates directories and spins up the docker image.
    """
    # p = pathlib.Path(__file__).parent.resolve()
    # get current script's location (dumb and ugly)
    if not (p := Path('./ros2_ws').is_dir()):
        try:
            logging.debug(f"Directory ros2_ws doesn't seem to exist. {p}")
            p.mkdir(parents=False)
        except FileExistsError as e:
            print(
                "Error: File ros2_ws exists, but is not a directory. \
                        Exiting...\n", file=sys.stderr)
            print(e)
            sys.exit(-1)
        p.chmod(0o0777)
        # TODO: Make this accessible for the docker's user only

    if not (p := Path('./rootfs')).is_dir():
        try:
            p.mkdir(parents=False)
        except FileExistsError as e:
            print("Error: File rootfs exists, but is not a directory. \
                    Exiting... \n", file=sys.stderr)
            print(e)
            sys.exit(-1)
        p.chmod(0o0777)
        # TODO: make this accessible for the docker's user only

    if not (p := Path('./.dockerignore')).exists():
        try:
            p.touch()
        except FileExistsError:
            print("Dockerignore exists. Skipping...")
            sys.exit(-1)
    # This returns an error if permissions are unset

    print("Building docker image...")

    subprocess.run(["docker", "build",
                    "-t", "crospile",
                    "-f", "Dockerfile",
                    "--build-arg", f"TARGET_ARCH={target_arch}",
                    "--build-arg", f"TOOLCHAIN_URL={url}",
                    "."],
                   check=True)

    print("Running docker...")

    subprocess.run(["docker", "run", "-it",
                    "--device", "/dev/fuse",
                    "--cap-add", "SYS_ADMIN",
                    "--security-opt", "apparmor:unconfined",
                    "-v", "./rootfs:/home/develop/rootfs",
                    "-v", "./ros2_ws:/home/develop/ros2_ws",
                    "crospile", "/bin/bash"],
                   check=True)


def main():
    global TARGET_ARCH
    global OFFLINE
    global URL
    # TODO : Return parsed arguments back to main() please
    if sys.argv[1:]:
        parse_opts()
    else:
        OFFLINE = False
        logging.basicConfig(level=logging.INFO)
    print(f"Starting compilation on Host Architecture: {get_host_arch()}")
    if not OFFLINE:
        ssh_login = input("Enter ssh user login info: user@IP ")
        subprocess.Popen(
                ["ssh", ssh_login], stdout=sys.stdout,
                stdin=sys.stdin).communicate()

    logging.debug(f"Target arch={TARGET_ARCH}")
    if TARGET_ARCH:
        logging.info(
                "TARGET_ARCH supplied, assuming we're running from a script."
                )
    elif not TARGET_ARCH and not OFFLINE:
        # get arch
        TARGET_ARCH = get_arch()
    else:
        TARGET_ARCH = input("Please enter the desired target architecture:")
    logging.debug(f"TARGET_ARCH={TARGET_ARCH}")

    # add rsync for online mode

    if TARGET_ARCH:
        start_docker(TARGET_ARCH, URL)
        # ~~catch an error related to lack of permissions~~ no longer true;
        # the exceptions are done now in another python file.

    else:
        print("Target Arch not provided. Nothing to do.")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("Keyboard interrupt\n")

# Details of the script:
# Aborted Get the information about the host -> extract architecture
#
# Allow user to supply the links as positional arguments to the script
