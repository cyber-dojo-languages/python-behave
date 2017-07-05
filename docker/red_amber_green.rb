
lambda { |stdout,stderr,status|
  output = stdout + stderr
  return :red   if /Failing scenarios/.match(output)
  return :green if /, 0 failed, /.match(output)
  return :amber
}
