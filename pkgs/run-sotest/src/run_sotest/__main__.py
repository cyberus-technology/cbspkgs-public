#######################################
#                                     #
#  Copyright Cyberus Technology GmbH  #
#           All rights reserved       #
#                                     #
#######################################

import argparse
import os
import requests
import sys

from .poll_test_run import poll_test_run

HTTP_STATUS_OK = 200


def parse_cmdline_args():
    """Command line parsing"""
    parser = argparse.ArgumentParser(description="Sotest Test Creator")
    parser.add_argument("sotest_url", help="Base URL to SoTest's web UI")
    parser.add_argument("sotest_config", help="Config with a list of boot items")
    parser.add_argument(
        "--boot_files", required=True, help="URL or local path to an artifacts.zip"
    )
    parser.add_argument(
        "--url", required=True, help="URL to be linked to in the web UI"
    )
    parser.add_argument("--name", required=True, help="Name of the TestRun")
    parser.add_argument(
        "--user", required=True, help="Username to be shown in the web UI"
    )
    parser.add_argument(
        "--poll",
        required=False,
        action="store_true",
        help="Create testrun and then block and poll until testrun is completed",
    )
    parser.add_argument(
        "--nopoll",
        required=False,
        action="store_true",
        help="Create testrun and then return immediately",
    )
    parser.add_argument(
        "--priority",
        required=False,
        default=0,
        help="Priority to be assigned to a test run. Jobs with numerically higher priority preempt lower-priority jobs. Can be negative, default = 0.",
    )
    parser.add_argument(
        "--testrun_id_file",
        required=False,
        help="File to store the created test run id in (overwrites any existing file).",
    )
    return parser.parse_args()


def create_test_run(args):
    """Creates a Sotest test run for the given config"""
    url = "{}/test_runs".format(args.sotest_url)
    files = {"config": open(args.sotest_config, "rb")}
    params = {
        "url": args.url,
        "user": args.user,
        "name": args.name,
        "priority": args.priority,
    }

    # Check if boot files are a valid local path, assume URL otherwise
    try:
        files["boot_files"] = open(args.boot_files, "rb")
    except:
        params["boot_files_url"] = args.boot_files

    auth_user = os.environ.get("SOTEST_USER", None)
    auth_pass = os.environ.get("SOTEST_PASS", None)
    if auth_user is not None and auth_pass is not None:
        r = requests.post(url, files=files, data=params, auth=(auth_user, auth_pass))
    else:
        r = requests.post(url, files=files, data=params)

    if r.status_code != HTTP_STATUS_OK:
        sys.exit("Testrun Creation failed: {}".format(r.text))

    return r.text


def main():
    cmdline_args = parse_cmdline_args()

    if cmdline_args.poll == cmdline_args.nopoll:
        raise Exception("Either --poll or --nopoll must be used.")

    tr_id = create_test_run(cmdline_args)

    # Flush output of the URL, so users see the URL while waiting.
    print("{}/test_runs/{}".format(cmdline_args.sotest_url, tr_id), flush=True)

    if cmdline_args.testrun_id_file:
        with open(cmdline_args.testrun_id_file, "w") as fil:
            fil.write(tr_id)

    if cmdline_args.poll:
        poll_test_run(cmdline_args.sotest_url, tr_id)


if __name__ == "__main__":
    main()
