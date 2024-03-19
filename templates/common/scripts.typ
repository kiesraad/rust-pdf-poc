#let input_digit() = {
  box(width: 14pt, height: 9pt)[
    #path(
      stroke: black,
      closed: false,
      (15%, 0%),
      (0%, 0%),
      (0%, 100%),
      (100%, 100%),
      (100%, 0%),
      (85%, 0%),
    )
  ]
}

#let input_date() = [
  #input_digit() #input_digit() - #input_digit() #input_digit() - #input_digit() #input_digit() #input_digit() #input_digit() (dd-mm-jjjj)
]

#let format_sha256(sha256) = upper({
  sha256.enumerate().fold(let r, (r, c) => {
    return r + c
  });
});
