#!/usr/bin/env bats

load bats-support-clone
load test_helper/bats-support/load
load test_helper/redhatcop-bats-library/load

setup_file() {
  rm -rf /tmp/rhcop
}

@test "policy/check-image - accept" {
  tmp=$(split_files "policy/check-image/test_data/unit")

  cmd="oc create -f ${tmp}/accept.yml --dry-run=server -n kyverno-verifyimages-blog"
  run ${cmd}

  print_info "${status}" "${output}" "${cmd}" "${tmp}"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "deployment.apps/signedimage created (server dry run)" ]]
  [[ "${#lines[@]}" -eq 1 ]]
}

@test "policy/check-image - reject" {
  tmp=$(split_files "policy/check-image/test_data/unit")

  cmd="oc create -f ${tmp}/reject.yml --dry-run=server -n kyverno-verifyimages-blog"
  run ${cmd}

  print_info "${status}" "${output}" "${cmd}" "${tmp}"
  [ "$status" -eq 1 ]
  [[ "${lines[1]}" == *"unsignedimage was blocked due to the following policies" ]]
  [[ "${#lines[@]}" -eq 6 ]]
}