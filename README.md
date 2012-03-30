# Twitter CLI [![Build Status](https://secure.travis-ci.org/sferik/t.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/sferik/t.png?travis)][gemnasium]
### A command-line power tool for Twitter.

The CLI attempts to mimic the [Twitter SMS commands][sms] wherever possible,
however it offers many more commands than are available via SMS.

[travis]: http://travis-ci.org/sferik/t
[gemnasium]: https://gemnasium.com/sferik/t
[gem]: https://rubygems.org/gems/twitter
[sms]: https://support.twitter.com/articles/14020-twitter-sms-command

## <a name="installation"></a>Installation
    gem install t


## <a name="configuration"></a>Configuration

Because Twitter requires OAuth for most of its functionality, you'll need to
register a new application at <http://dev.twitter.com/apps/new>. Once you
create your application make sure to set the "Application Type" to "Read, Write
and Access direct messages", otherwise you won't be able to post status updates
or send direct messages via the CLI.

Once you have registered your application, you'll be given a consumer key and
secret, which you can use to authorize your Twitter account.

    t authorize --consumer-key YOUR_CONSUMER_KEY --consumer-secret YOUR_CONSUMER_SECRET

This will open a new browser window where you can authenticate to Twitter and
then enter the returned PIN back into the terminal.  Assuming that works,
you'll be authorized to use the CLI.

You can see a list of all the accounts you've authorized.

    t accounts

    sferik
      UDfNTpOz5ZDG4a6w7dIWj
      uuP7Xbl2mEfGMiDu1uIyFN
    gem
      thG9EfWoADtIr6NjbL9ON (default)

Notice that one account is marked as the default. To change the default use the
`set` subcommand, passing either just the username, if it's unambiguous, or the
username and consumer key pair, like so:

    t set default sferik thG9EfWoADtIr6NjbL9ON

Account information is stored in the YAML-formatted file `~/.trc`.

## <a name="examples"></a>Usage Examples

Typing `t help` will give you a list of all the available commands. You can
type `t help TASK` to get help for a specific command.

    t help

### <a name="update"></a>Update your status

    t update "I'm tweeting from the command line. Isn't that special?"

### <a name="dm"></a>Send a direct message

    t dm sferik "Want to get dinner tonight?"

### <a name="location"></a>Update the location field in your profile

    t set location "San Francisco"

### <a name="whois"></a>Retrieve profile information for a user

    t whois sferik

### <a name="stats"></a>Retrieve stats about a user

    t stats sferik

### <a name="suggest"></a>Return a user you might enjoy following

    t suggest

### <a name="follow-users"></a>Start following users

    t follow users sferik gem

### <a name="follow-followers"></a>Follow all followers (i.e. follow back)

    t follow followers

### <a name="unfollow-users"></a>Stop following users

    t unfollow users sferik gem

### <a name="unfollow-nonfollowers"></a>Unfollow all non-followers

    t unfollow nonfollowers

### <a name="list-create"></a>Create a list

    t list create presidents

### <a name="list-add-followers"></a>Add users to a list

    t list add users presidents BarackObama Jasonfinn

### <a name="list-add-friends"></a>Add all friends to a list

    t list add friends presidents

### <a name="list-add-followers"></a>Add all followers to a list

    t list add followers presidents

### <a name="list-add-followers"></a>Add all members of one list to another

    t list add listed democrats presidents

### <a name="follow-all-listed"></a>Follow all members of a list

    t follow listed presidents

### <a name="unfollow-all-listed"></a>Unfollow all members of a list

    t unfollow listed presidents

### <a name="list-timeline"></a>Retrieve the timeline of status updates from a list

    t list timeline presidents

### <a name="timeline"></a>Retrieve the timeline of status updates posted by you and the users you follow

    t timeline

### <a name="timeline-user"></a>Retrieve the timeline of status updates posted by a user

    t timeline sferik

### <a name="mentions"></a>Retrieve the timeline of status updates that mention you

    t mentions

### <a name="favorites"></a>Retrieve the timeline of status updates that you favorited

    t favorites

### <a name="reply"></a>Reply to a Tweet

    t reply sferik "Thanks Erik"

### <a name="retweet"></a>Send another user's latest Tweet to your followers

    t retweet sferik

### <a name="favorite"></a>Mark a user's latest Tweet as one of your favorites

    t favorite sferik

### <a name="search-all"></a>Retrieve the 20 most recent Tweets that match a specified query

    t search all "query"

### <a name="search-retweets"></a>Returns Tweets you've favorited that mach a specified query

    t search favorites "query"

### <a name="search-mentions"></a>Returns Tweets mentioning you that mach a specified query

    t search mentions "query"

### <a name="search-retweets"></a>Returns Tweets you've retweeted that mach a specified query

    t search retweets "query"

### <a name="search-timeline"></a>Retrieve Tweets in your timeline that match a specified query

    t search timeline "query"

### <a name="search-user"></a>Retrieve Tweets in a user's timeline that match a specified query

    t search user sferik "query"

## <a name="history"></a>History
![History](http://twitter.rubyforge.org/images/terminal_output.png "History")

The [twitter gem][gem] previously contained a command-line interface, up until
version 0.5.0, when it was [removed][]. This project is offered as a sucessor
to that effort, however it is a clean room implementation that contains none of
John Nunemaker's original code.

[removed]: https://github.com/jnunemaker/twitter/commit/dd2445e3e2c97f38b28a3f32ea902536b3897adf

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
4. Add specs for your feature or bug fix.
5. Run `bundle exec rake spec`. If your changes are not 100% covered, go back
   to step 4.
6. Commit and push your changes.
7. Submit a pull request. Please do not include changes to the gemspec,
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
