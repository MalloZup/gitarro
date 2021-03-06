#!/usr/bin/ruby

require 'English'
require 'octokit'
require 'optparse'
require_relative 'lib/gitarro/opt_parser'
require_relative 'lib/gitarro/git_op'
require_relative 'lib/gitarro/backend'

b = Backend.new
prs = b.open_newer_prs
exit 0 if prs.empty?

prs.each do |pr|
  puts '=' * 30 + "\n" + "TITLE_PR: #{pr.title}, NR: #{pr.number}\n" + '=' * 30
  # this check the last commit state, catch for review or not reviewd status.
  comm_st = b.client.status(b.repo, pr.head.sha)
  # pr number trigger.
  break if b.triggered_by_pr_number?(pr)
  # retrigger if magic word found
  b.retrigger_check(pr)
  # 0) do test for unreviewed pr
  break if b.unreviewed_new_pr?(pr, comm_st)
  # we run the test in 2 conditions:
  # 1) the context  is not set, test didnt run
  # 2) the pending status is set on commit, repeat always when pending set
  # check the conditions 1,2 and it they happens run_test
  break if b.reviewed_pr?(comm_st, pr)
end
STDOUT.flush
