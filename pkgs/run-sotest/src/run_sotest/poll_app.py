#######################################
#                                     #
#  Copyright Cyberus Technology GmbH  #
#           All rights reserved       #
#                                     #
#######################################

import argparse

from .poll_test_run import poll_test_run


def parse_cmdline_args():
    """Command line parsing"""
    parser = argparse.ArgumentParser(description="Sotest Test Creator")
    parser.add_argument("sotest_url", help="Base URL to SoTest's Web UI")
    parser.add_argument("--id", required=True, help="ID of the SoTest Test Run")
    return parser.parse_args()


def main():
    cmdline_args = parse_cmdline_args()

    # Flush output of the URL, so users see the URL while waiting.
    print(
        "{}/test_runs/{}".format(cmdline_args.sotest_url, cmdline_args.id), flush=True
    )

    poll_test_run(cmdline_args.sotest_url, cmdline_args.id)


if __name__ == "__main__":
    main()
