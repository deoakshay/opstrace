# to be `source`ed.

# ./build is supposed to be the directory containing the tsc compile output and
# single-binary builds.
export GOOGLE_APPLICATION_CREDENTIALS=./secrets/gcp-credentials.json


test_list() {
    set -o xtrace

    # Show complete `list` output for build log, confirm that this does not fail.
    ./build/bin/opstrace list ${OPSTRACE_CLOUD_PROVIDER} --log-level=debug

    # Confirm that current CI cluster is listed on stdout (grep exits non-zero
    # when there is no match). TODO: confirm that line starts with cluster name,
    # and that newline char comes right after cluster name.
    ./build/bin/opstrace list ${OPSTRACE_CLOUD_PROVIDER} | grep "${OPSTRACE_CLUSTER_NAME}"
    set +o xtrace

    # First, confirm that a debug log statement is emitted when stderr is
    # redirected to stdout. Then, confirm that no debug log statement is presented
    # on stdout (see opstrace-prelaunch/issues/998),
    # i.e. confirm that it is indeed emitted on stderr. For
    # the second part of the test, disable errexit mode tmprly because grep is
    # expected to fail. Note that the second part of the test relies on the fact
    # that a debug log statement *is* emitted as part of the `list` operation --
    # which is explicitly confirmed by the first part of the test. That is how the
    # two parts of the test form a logical unit.
    ./build/bin/opstrace list ${OPSTRACE_CLOUD_PROVIDER} --log-level debug 2>&1 | grep "debug"
    set +e
    ./build/bin/opstrace list ${OPSTRACE_CLOUD_PROVIDER} --log-level debug | grep "debug"
    if [[ $? != 0 ]]; then
        echo "confirmed that 'debug' not present on stdout"
    else
        echo "unexpected: 'debug' present on stdout"
        exit 1
    fi
    set -e
}

test_list

# Confirm status command returns exit code 0
./build/bin/opstrace status ${OPSTRACE_CLOUD_PROVIDER} ${OPSTRACE_CLUSTER_NAME} --cluster-config ./ci/cluster-config.yaml
