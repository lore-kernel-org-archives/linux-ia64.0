From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 18 Aug 2005 23:54:15 +0000
Subject: small glitch in my "test" branch
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F042C82C9@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It seems that a couple of days ago I managed to create a commit
that contained lots of changes from an earlier failed merge with
Linus.  While this left the contents of the files ok (as all the
extra changes were legitimately part of Linus' tree), it meant
that I had a commit with my Signed-off-by line that included
changes to ten files that I didn't want to change.

I've done some open-heart surgery on the test branch to fix this
(luckily I only had a few changes after this point ... and my
new strategy of having changes stashed in other branches in my
local tree made this even easier to fix).

But this does mean that anyone who has done a "git pull" from
my test branch might have some "interesting" times when they
next update from that branch.  You will definitely have some
cruft in your objects data base for all the commit objects that
I recreated when fixing this.

Sorry for any inconvenience.

-Tony
