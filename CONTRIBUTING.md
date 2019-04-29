How to Contribute
=================

Notes
-----

- Never force push branch `master`. Unless you know what you are doing!
- Limit changes to the area you are working on. Do not commit whitespace or
  indentation changes to the whole file as part of your feature.
- Be cautious when you are sharing a branch. If you share a branch please read
  the section below.
- Branches are built when a [Pull Request](https://hub.arthurly.com/projects/devops-ci/wiki/Building_Pull_Requests) is made.
- **You** are responsible for the code you put in to master. Have other devs
  look at it when the build has finished.
- Respond to Pull Requests with comments if more work is needed, otherwise reply
  with "Ready to merge", +1 or `:ship:`.

Coding Style
------------

- Follow the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) as
  much as possible.
- Do not rewrite code to fit this style guide unless you are actively working on
  the code as part of your feature, or you make a specific Pull Request to tidy
  the area up.
- If you change code, **you** are responsible for it.
- <u>Test</u> your code with [Test::Unit](guides.rubyonrails.org/v2.3.11/testing.html).

### Documentation

- Use [Tomdoc](http://tomdoc.org) for inline documentation, except:
- Use [Markdown](http://github.github.com/github-flavored-markdown) for long
  form documentation in `/doc`.

Adding a feature
----------------

This is the workflow that you should follow when developing a feature.

```sh
# Branch from master
$ git fetch origin
$ git checkout -b my_feature origin/master --no-track

# Do some work
# ...

# Incorporate latest changes from master
$ git fetch origin
$ git checkout my_feature
$ git rebase origin/master

# Update GitHub
$ git push --force origin my_feature

# Create a Pull Request and get comments

# Master updated again?!
$ git fetch origin
$ git checkout my_feature
$ git rebase origin/master
$ git push --force origin my_feature
```

Pull Requests
-------------

- When opening a pull request, if it has some associated ticket then please
  include the ticket number for reference at the start of the title, for
  example `[hub#12345] Some Feature`.
- After merging a pull request please delete the associated branch (you can use
  the GitHub feature to do this).

### Merging a pull request manually

- `git fetch`, `git checkout <branch>`, `git merge origin/<branch> --ff-only`
  (If the FastForward merge fails then you need to update your local branch to
  what origin has. Most of the time you want `git reset --hard origin/<branch>`
  however please note you may lose commits which origin doesnt have!
- `git checkout master`, `git merge <branch> --no-ff -m "Merge pull request #123
  from <organization>/<branch>"`
- `git commit --amend` to amend the commit message if you wish to explain the
  merge.

For GitHub to recognize the merge, you would have to merge the HEAD of the
branch which GitHub has. If you modify the branch locally and merge into master
without updating the branch on GitHub then the pull request will remain open.

Naming Conventions
------------------

### Branches

- `1234-issue_with_login` (Lowercase, underscores for spaces, hyphen for
  separation between optional ticket number).
- `s4321-some_support_ticket` (Preceding lowercase `s` before ticket number).

### Commits

Assume the commit message starts with "This commit will".

```
# Good
set the session when user logs in

# Bad
log in
```

Don't be afraid to use a full commit message if you can describe your changes
better.

Follow the advice from [A Note About Git Commit Messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)

Sharing a branch
----------------

Sharing a branch is discouraged as there are many traps you can fall into. If you
need to share a feature then normally the feature is too big and should be split
into smaller sub features / tasks. If this is not possible it is still
recommened that only one developer should be working on the branch even if it
takes longer whilst the other developer work on something else.

However, if you wish to share a branch:

Before you push or rewrite history (e.g. rebase) do:

```sh
$ git fetch origin
$ git rebase origin/feature-x
```

This will update your branch with the latest version on GitHub. Please note that
this will minimise the risks however bad stuff can still happen.

Another way of sharing a branch:

Have a branch called `feature-x` which then each developer will prefix their 
names on:

- `john/feature-x`
- `bob/feature-x`

To update the personal branch you would:

```sh
$ git fetch origin
$ git checkout john/feature-x
$ git rebase origin/feature-x
```

Then to merge it into the main feature branch and update origin:

- `git checkout feature-x` - Assuming feature-x is up to date
- `git merge john/feature-x --ff-only`
- `git push origin feature-x`

You would only use fast forward therefore the git history will have no trace of
the personal branches.