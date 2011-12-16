# Twitter CLI
A command-line interface for Twitter, powered by the [twitter gem][gem]. The
CLI attempts to mimic the [Twitter SMS commands][sms] wherever possible,
however it offers more commands than are available via SMS.

[gem]: https://rubygems.org/gems/twitter
[sms]: https://support.twitter.com/articles/14020-twitter-sms-command

## <a name="history"></a>History
![History](http://twitter.rubyforge.org/images/terminal_output.png "History")

The [twitter gem][gem] previously contained a command-line interface, up until
version 0.5.0, when it was [removed][]. This project is offered as a sucessor
to that effort, however it is a clean room implementation that contains none of
John Nunemaker's original code.

[removed]: https://github.com/jnunemaker/twitter/commit/dd2445e3e2c97f38b28a3f32ea902536b3897adf

## <a name="installation"></a>Installation
    gem install t

## <a name="build"></a>Build Status
[![Build Status](https://secure.travis-ci.org/sferik/t.png?branch=master)][travis]

[travis]: http://travis-ci.org/sferik/t

## <a name="dependencies"></a>Dependency Status
[![Dependency Status](https://gemnasium.com/sferik/t.png?travis)][gemnasium]

[gemnasium]: https://gemnasium.com/sferik/t

## <a name="examples"></a>Usage Examples
Typing `t help` will give you a list of all the available commands. You can
type `t help TASK` to get help for a specific command.

    t help

Because Twitter requires OAuth for most of its functionality, you'll need to
register a new application at <http://dev.twitter.com/apps/new>. Once you
create your application make sure to set the "Application Type" to "Read, Write
and Access direct messages", otherwise you won't be able to post status updates
or send direct messages via the CLI.

Once you have registered your application, you'll be given a consumer key and
secret, which you can use to authorize your Twitter account.

    t authorize --consumer-key YOUR_CONSUMER_KEY --consumer-secret YOUR_CONSUMER_SECRET

This will open a new browser window where you can authenticate to Twitter and
then enter the returned PIN back into the terminal.  Assuming all that works
well, you will be authorized to make requests with the API.

You can see a list of all the accounts you've authorized.

    t accounts

    sferik
      UDfNTpOz5ZDG4a6w7dIWj
      uuP7Xbl2mEfGMiDu1uIyFN
    gem
      thG9EfWoADtIr6NjbL9ON (default)

Notice that one account is marked as the default. To change the default use the
`set` subcommand, passing either just the username, if it's unambiguous, or the
username and consumer key pair:

    t set default sferik thG9EfWoADtIr6NjbL9ON

Account information is stored in the YAML-formatted file `~/.trc`.

### <a name="update"></a>Update your status

    t update "I'm tweeting from the command line. Isn't that special?"

### <a name="dm"></a>Send a user a private message

    t dm sferik "Want to get dinner together tonight?"

### <a name="location"></a>Update the location field in your profile

    t set location "San Francisco"

### <a name="get"></a>Retrieve the latest Tweet posted by a user

    t get sferik

### <a name="whois"></a>Retrieve profile information for a user

    t whois sferik

### <a name="stats"></a>Get stats about a user

    t stats sferik

### <a name="suggest"></a>Return a user you might enjoy following

    t suggest

### <a name="follow-users"></a>Start following @sferik and @gem

    t follow users sferik gem

### <a name="follow-all-followers"></a>Following all followers

    t follow all followers

### <a name="follow-all-listed"></a>Following all members of the list named "presidents"

    t follow all listed presidents

### <a name="unfollow-users"></a>Stop following @sferik and @gem

    t unfollow users sferik gem

### <a name="unfollow-all-nonfollowers"></a>Unfollow all non-followers

    t unfollow all nonfollowers

### <a name="unfollow-all-listed"></a>Unfollow all members of the list named "presidents"

    t unfollow all listed presidents

### <a name="timeline"></a>Retrieve the timeline of status updates from users you are following

    t timeline

### <a name="mentions"></a>Retrieve the timeline of status updates that mention you

    t mentions

### <a name="favorites"></a>Retrieve the timeline of status updates that you favorited

    t favorites

### <a name="list-timeline"></a>Retrieve the timeline of status updates from the list presidents

    t list timeline presidents

### <a name="reply"></a>Reply to a Tweet

    t reply sferik "Thanks Erik"

### <a name="retweet"></a>Send another user's latest Tweet to your followers

    t retweet sferik

### <a name="favorite"></a>Mark a user's latest Tweet as one of your favorites

    t favorite sferik

## <a name="contributing"></a>Contributing
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

[issues]: https://github.com/sferik/t/issues

## <a name="issues"></a>Submitting an Issue
We use the [GitHub issue tracker][issues] to track bugs and features. Before
submitting a bug report or feature request, check to make sure it hasn't
already been submitted. You can indicate support for an existing issue by
voting it up. When submitting a bug report, please include a [Gist][] that
includes a stack trace and any details that may be necessary to reproduce the
bug, including your gem version, Ruby version, and operating system. Ideally, a
bug report should include a pull request with failing specs.

[gist]: https://gist.github.com/

## <a name="pulls"></a>Submitting a Pull Request
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

## <a name="versions"></a>Supported Ruby Versions
This library aims to support and is [tested against][travis] the following Ruby
implementations:

* Ruby 1.8.7
* Ruby 1.9.2
* Ruby 1.9.3
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

## <a name="copyright"></a>Copyright
Copyright (c) 2011 Erik Michaels-Ober. See [LICENSE][] for details.

[license]: https://github.com/sferik/t/blob/master/LICENSE.md
