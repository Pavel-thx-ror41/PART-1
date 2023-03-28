#!/usr/bin/env ruby
# https://gist.github.com/ndbroadbent/3ee4e1b9740a381bd7ecc098eb9e090f
# Save this to ".git/hooks/commit-msg", then run: "chmod +x .git/hooks/commit-msg"

require 'english'
require 'yaml'

commit_message = File.read(ARGV[0])
if commit_message.match?(/^(WIP|te?mp)/)
  puts 'Skipping Rubocop for temporary commit.'
  exit
end

rubocop_config = YAML.load_file(File.expand_path('../.rubocop.yml', __dir__))
excluded_files = rubocop_config['AllCops']['Exclude']

ADDED_OR_MODIFIED = /A|AM|^M/

added_or_modified = `git status --porcelain`.split("\n").select do |file_name_with_status|
  file_name_with_status =~ ADDED_OR_MODIFIED
end
filenames = added_or_modified.map do |file_name_with_status|
  file_name_with_status.split(' ')[1]
end
changed_ruby_files = filenames.select do |file|
  File.extname(file) == '.rb' &&
    excluded_files.none? { |pattern| File.fnmatch(pattern, file) }
end
exit if changed_ruby_files.empty?

puts 'Running Rubocop...'
system('rubocop', *changed_ruby_files)
rubocop_status = $CHILD_STATUS

unless rubocop_status.success?
  puts "Rubocop reported some violations. Trying to autocorrect these with 'rubocop -a'... "
  system('rubocop', '-a', *changed_ruby_files)
  rubocop_autocorrect_status = $CHILD_STATUS
  if rubocop_autocorrect_status.success?
    puts "\nRubocop was able to automatically correct all of the violations.\n" \
      'Please review these automatic corrections and then commit the changes.'
  else
    puts "\nRubocop was not able to automatically correct all of the violations.\n" \
      'Please review all of the automatic corrections and fix the remaining violations.'
  end
  exit rubocop_status.to_s[-1].to_i
end

system('git', 'add', *changed_ruby_files)
