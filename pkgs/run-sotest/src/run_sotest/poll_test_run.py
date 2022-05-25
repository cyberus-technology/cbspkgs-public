#######################################
#                                     #
#  Copyright Cyberus Technology GmbH  #
#           All rights reserved       #
#                                     #
#######################################

import requests
import sys
import time

HTTP_STATUS_OK = 200
REQUEST_HEADERS = {"Accept": "application/json"}


def query_test_run(sotest_url, testrun_id):
    """Queries the status of a test run"""
    url = "{}/test_runs/{}/status".format(sotest_url, testrun_id)
    r = requests.get(url, headers=REQUEST_HEADERS)

    if r.status_code != HTTP_STATUS_OK:
        sys.exit("Testrun query failed: {}".format(r.text))

    return r.json()


def poll_test_run(sotest_url, testrun_id):
    """Queries the status of a test run until it is no longer running and handles the result"""
    while True:
        result = query_test_run(sotest_url, testrun_id)
        if result != "unfinished":
            break
        time.sleep(10)

    if result == "success":
        print("Test successful")
    elif result == "fail":
        sys.exit("Test failed")
    elif result == "disabled":
        sys.exit("Test has been aborted")
    else:
        sys.exit("Unexpected response: {}".format(result))
