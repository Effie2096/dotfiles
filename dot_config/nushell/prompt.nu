export def dir_component [] {
  mut prompt = $env.PWD
  if (($env.PWD | str starts-with $nu.home-dir)) {
    $prompt = $"($prompt | str replace $nu.home-dir "~")"
  }
  $prompt
}

export def status_component [] {
  [
    (
      if $env.LAST_EXIT_CODE != 0 {
        (ansi { fg: "#CC0000" })
      } else {
        (ansi { fg: "#606060" })
      }
    )
    $env.LAST_EXIT_CODE
    (char space)
    (ansi reset)
  ] | str join
}

export def time_component [] {
  [
    (ansi yellow)
    (date now | format date %H:%M:%S)
    (ansi reset)
  ] | str join
}

export def duration_component [] {
  (
    if (("CMD_DURATION_MS" in $env) and (($env.CMD_DURATION_MS | into int) > 0)) {
      let dur = ($"($env.CMD_DURATION_MS)ms" | into duration)
        [(ansi cyan) ($dur | into duration) (char space)] | str join
    }
  )
}

export def shell_component [] {
  (
    $env.SHELL
  )
}

export def git_component [] {
  let stat = gstat
  (
    if ($stat.repo_name != "no_repository") {
      [
      (char space)
      (ansi grey)
      ""
      ($stat.branch)
      (
        if ($stat.tag != "no_tag") {
          [
            (char space)
            (ansi magenta)
            " "
            $stat.tag
          ] | str join
        }
      )
      (
        if ($stat.wt_modified > 0) {
          [
            (char space)
            (ansi light_yellow)
            "+"
            $stat.wt_modified
          ] | str join
        }
      )
      (ansi reset)
      ] | str join
    }
  )
}
