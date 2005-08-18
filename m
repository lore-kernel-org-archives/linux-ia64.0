From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 18 Aug 2005 05:05:51 +0000
Subject: RE: change to the ia64 GIT trees
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F042C7855@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F042945E9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F042945E9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Instead of having separate trees for test and release, there
>> is now just one tree which contains "test" and "release" branches.
>
>Does anyone know how one gets to these using cogito?  Or maybe I
>should just not use cogito?

I started off using cogito in the early days of GIT, but I didn't
keep up with its development ... so I don't know how to pull these
with cogito.  This might be a case where pure GIT and cogito play
nice together ... so you could try a "git pull" to get each branch
and see what cogito thinks of it.  A git branch is just an extra
file in .git/refs/heads/ with the SHA1 of the head of that branch.

>> You can pull each of the branches separately with:
>> 
>>  $ git pull rsync://rsync.kernel.org/..../aegl/linux-2.6 test
>> or
>>  $ git pull rsync://rsync.kernel.org/..../aegl/linux-2.6 release
>
>Is that supposed to be linux-2.6.git?

Doh!  Yes, I can't remember the name of my own GIT tree, isn't that
sad.

>Along the same lines, when I look at the web view at
>
>http://www.kernel.org/git/?p=linux/kernel/git/aegl/linux-2.6.git;a=summ
ary
>
>and especially the "tree" view (which I use a bit to see what has
>changed in a file) what branch am I looking at there, the test or the
>release? 

The ".git/HEAD" symlink in my tree points to the "release" branch, so
that's what gitweb will show by default.

But, if you scroll down to the bottom of the summary page you'll
see links for the test/release branches.  Click on "test" and the
page you get to will have a "tree" link that allows you to browse
the test tree.  You can also browse a historic tree by searching
back to some old commit, and clicking the "tree" you find there.

-Tony

