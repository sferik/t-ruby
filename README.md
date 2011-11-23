# Twitter CLI
A command-line interface for Twitter, powered by the [twitter gem][gem]. The
CLI attempts to mimic the [Twitter SMS commands][sms] wherever possible,
however it offers more commands than are available via SMS.

[gem]: https://rubygems.org/gems/twitter
[sms]: https://support.twitter.com/articles/14020-twitter-sms-command

## <a name="history">History</a>
![History](http://twitter.rubyforge.org/images/terminal_output.png "History")

The [twitter gem][gem] previously contained a command-line interface, up until
version 0.5.0, when it was [removed][]. This project is offered as a sucessor
to that effort, however it is a clean room implementation that contains none of
John Nunemaker's original code.

[removed]: https://github.com/jnunemaker/twitter/commit/dd2445e3e2c97f38b28a3f32ea902536b3897adf

## <a name="installation">Installation</a>
    gem install t

## <a name="ci">Continuous Integration</a>
[![Build Status](https://secure.travis-ci.org/sferik/t.png)][travis]

[travis]: http://travis-ci.org/sferik/t

## <a name="examples">Usage Examples</a>
Typing `t help` will give you a list of all the available commands. You can
type `t help TASK` to get help for a specific command.

    t help

Because Twitter requires OAuth for most of it's functionality, you'll need to
register a new application at <http://dev.twitter.com/apps/new>. Once you
create your application make sure to set the "Application Type" to "Read, Write
and Access direct messages", otherwise you won't be able to post status updates
or send direct messages via the CLI.

Once you have registered your application, you'll be assigned a consumer key
and secret, which you can use to authorize your Twitter account.

    t authorize --consumer-key YOUR_CONSUMER_KEY --consumer-secret YOUR_CONSUMER_SECRET

This will open a new browser window where you can authenticate to Twitter.

You can see a list of all the accounts you've authorized.

    t accounts

You can easily switch between accounts.

    t set default sferik

Incidentally, account information is stored in YAML format in `~/.trc`.

### <a name="update">Update your status</a>

    t update "I'm tweeting from the command line, powered by @gem."

### <a name="dm">Send a user a private message</a>

    t dm sferik "Want to get dinner together tonight?"

### <a name="location">Update the location field in your profile</a>

    t set location San Francisco

### <a name="get">Retrieve the latest Tweet posted by a user</a>

    t get sferik

### <a name="whois">Retrieve profile information for a user</a>

    t whois sferik

### <a name="stats">Get stats about a user</a>

    t stats sferik

### <a name="suggest">Return a listing of users you might enjoy following</a>

    t suggest

### <a name="follow">Start following a user</a>

    t follow sferik

### <a name="leave">Stop following a user</a>

    t unfollow sferik

### <a name="timeline">Retrieve the timeline of status updates from users you are following</a>

    t timeline

### <a name="mentions">Retrieve the timeline of status updates that mention you</a>

    t mentions

### <a name="reply">Reply to a Tweet</a>

    t reply sferik Thanks

### <a name="retweet">Send another user's latest Tweet to your followers</a>

    t retweet sferik

### <a name="favorite">Mark a user's latest Tweet as one of your favorites</a>

    t favorite sferik

## <a name="contributing">Contributing</a>
In the spirit of [free software][fsf], **everyone** is encouraged to help
improve this project.

[fsf]: http://www.fsf.org/licensing/essays/free-sw.html

Here are some ways *you* can contribute:

* by using alpha, beta, and prerelease versions
* by reporting bugs
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code (**no patch is too small**: fix typos, add comments, clean up
  inconsistent whitespace)
* by refactoring code
* by closing [issues][]
* by reviewing patches
* by financially (please send bitcoin donations to
  1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L)

[issues]: https://github.com/sferik/t/issues

## <a name="issues">Submitting an Issue</a>
We use the [GitHub issue tracker][issues] to track bugs and features. Before
submitting a bug report or feature request, check to make sure it hasn't
already been submitted. You can indicate support for an existing issuse by
voting it up. When submitting a bug report, please include a
[Gist](https://gist.github.com/) that includes a stack trace and any details
that may be necessary to reproduce the bug, including your gem version, Ruby
version, and operating system. Ideally, a bug report should include a pull
request with failing specs.

## <a name="pulls">Submitting a Pull Request</a>
1. Fork the project.
2. Create a topic branch.
3. Implement your feature or bug fix.
4. Add documentation for your feature or bug fix.
5. Run `bundle exec rake doc:yard`. If your changes are not 100%
   documented, go back to step 4.
6. Add specs for your feature or bug fix.
7. Run `bundle exec rake spec`. If your changes are not 100% covered, go
   back to step 6.
8. Commit and push your changes.
9. Submit a pull request. Please do not include changes to the gemspec,
   version, or history file. (If you want to create your own version for some
   reason, please do so in a separate commit.)

## <a name="rubies">Supported Rubies</a>
This library aims to support and is [tested against][travis] the following Ruby
implementations:

* Ruby 1.8.7
* Ruby 1.9.1
* Ruby 1.9.2
* [JRuby][]
* [Rubinius][]
* [Ruby Enterprise Edition][ree]

[jruby]: http://www.jruby.org/
[rubinius]: http://rubini.us/
[ree]: http://www.rubyenterpriseedition.com/

If something doesn't work on one of these interpreters, it should be considered
a bug.

This library may inadvertently work (or seem to work) on other Ruby
implementations, however support will only be provided for the versions listed
above.

If you would like this library to support another Ruby version, you may
volunteer to be a maintainer. Being a maintainer entails making sure all tests
run and pass on that implementation. When something breaks on your
implementation, you will be personally responsible for providing patches in a
timely fashion. If critical issues for a particular implementation exist at the
time of a major release, support for that Ruby version may be dropped.

## <a name="copyright">Copyright</a>
Copyright (c) 2011 Erik Michaels-Ober. See [LICENSE][] for details.

[license]: https://github.com/sferik/t/blob/master/LICENSE.md
