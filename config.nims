import strformat

const NIM = "nim"
const NIMFLAGS = "--threads:on"

const EXECARRAY = ["caffe_vis"]
const TESTARRAY = ["test1"]

task clean, "Removes build files.":
  exec "rm -rf bin ~/.cache/nim src/nimcache tests/nimcache"
  exec "find . -type f  ! -name \"*.*\"  -delete"

task build, "Builds the apps.":
  exec "mkdir -p bin"
  for value in EXECARRAY:
    exec fmt"{NIM} c {NIMFLAGS} -o:bin/{value} src/{value}.nim"

task test, "Tests the code.":
  for value in TESTARRAY:
    exec fmt"{NIM} c {NIMFLAGS} -r tests/{value}.nim"
    echo fmt"Passed {value}."
