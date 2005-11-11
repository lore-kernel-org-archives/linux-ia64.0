From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 11 Nov 2005 00:59:31 +0000
Subject: GIT maintenance on ia64 test tree
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04EE77E4@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, git@vger.kernel.org
Cc: Andrew Morton <akpm@osdl.org>

The way that I'm using GIT to maintain my test/release
trees results in the test tree building a history of
extra fluff (lots of auto-updates from Linus, plus all
the merge-commits to bring in each of the patch-sets, plus
some mistakes from when I goofed with GIT).

So, I'm going to periodically blow away the test branch
and re-create a clean version.  This mail is advance
notice that I'm going to do this when Linus releases
2.6.15-rc1 (a convenient point since I just sent everything
that was cooking in test to Linus ... so the test tree is
currently empty).

What this means is that the new "test" branch won't have
any connection to the old "test" branch.  So a "git pull"
or "git fetch" will fail.  To fix this in native git I *think*
you need to run (git list copied in the hope that if this is
tragically wrong, or overly complex, someone will take pity
and explain how it should be done):

 $ git checkout
{any-branch-other-than-the-one-you-track-my-test-tree-with}
 $ git branch -D test
 $ git branch test v2.6.15-rc1

Note that this will orphan all the objects relating to the
history of the test branch.  You can clean up with:

 $ git prune

BUT, this will also throw away any other orphaned stuff too, so
only do this if you are ok with ditching this.  You could run

 $ git fsck-objects

before any of the above to see whether you have any orphans.

Cogito users ... I have no idea.  First one to figure it out
please post a recipe.

-Tony
