From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 28 Apr 2005 19:19:49 +0000
Subject: BK to GIT migration status for ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F035ECFEA@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It's been a hectic month (well, not even a month ... this
is only day 24 of the great migration :)

I've set up a pair of GIT trees on kernel.org for ia64 to
keep track of changes.

1) rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git

This is the "to-linus" tree.  Anything commited here is queued to go
into Linus' tree next time he does a pull from me.  Some obviously
correct (to me) patches will go directly into this tree, but most
patches will spend time in the test tree.

2) rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/test-2.6.git

This is the "to-andrew" tree.  Andrew has a script to pull automatically
from here, so changes in this tree will usually end up in the next
"-mm" patch.

I'm not going to play games renaming these trees each release (pauses
to wait for cheering to die down) this didn't really work for me the
way it did for Len (from whom I stole the idea) because my workflow
isn't quite the same.


My BK trees are now offically dead.  Most of the live patches that
were cooking in the "-test" tree have gone into Linus's tree.  The
exception is a dozen or so syscall improvement patches from David
that are still cooking in -mm, they are in the test-2.6.git tree to
finish up, and will move on to Linus after 2.6.12 comes out.
If you see anything that was in a BK tree, and isn't in GIT, then
please let me know.


I'm still working out the details of internal workflow ... trees for
patches to sit in while the testing phase in -mm runs its course. I
don't want to be constrained to have every patch test for the same
period of time ... so I think I still need a small forest of trees from
which to cherry pick into the two public trees.

-Tony
