task :clean do
  `rm -rf *~`
  `rm -rf */*~`
  `rm -rf */*/*~`
  `rm -rf pkg`
  `rm -rf doc`
  `rm -rf .yardoc`
  `rm -f Gemfile.lock`
end
