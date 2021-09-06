#!/usr/bin/env bats

load bats-support-clone
load test_helper/bats-support/load
load test_helper/redhatcop-bats-library/load

setup_file() {
  export project_name="kyverno-undertest-$(date +'%d%m%Y-%H%M%S')"

  rm -rf /tmp/rhcop
  oc process --local -f test/resources/namespace-under-test.yml -p=PROJECT_NAME=${project_name} | oc create -f -
}

teardown_file() {
  if [[ -n ${project_name} ]]; then
    oc delete namespace/${project_name}
  fi
}

teardown() {
  if [[ -n "${tmp}" ]]; then
    oc delete -f "${tmp}" --ignore-not-found=true --wait=true > /dev/null 2>&1
  fi
}

@test "policy/check-image - accept" {
  tmp=$(split_files "policy/check-image/test_data/unit")

  cmd="oc create -f ${tmp}/accept.yml -n ${project_name}"
  run ${cmd}

  print_info "${status}" "${output}" "${cmd}" "${tmp}"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "deployment.apps/signedimage created" ]]
  [[ "${#lines[@]}" -eq 1 ]]
}

@test "policy/check-image - reject" {
  tmp=$(split_files "policy/check-image/test_data/unit")

  cmd="oc create -f ${tmp}/reject.yml -n ${project_name}"
  run ${cmd}

  print_info "${status}" "${output}" "${cmd}" "${tmp}"
  [ "$status" -eq 1 ]
  [[ "${lines[1]}" == *"unsignedimage was blocked due to the following policies" ]]
  [[ "${#lines[@]}" -eq 6 ]]
}