From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 Jul 2004 17:04:28 +0000
Subject: next 3 months
Message-Id: <200407271704.i6RH4SQU024357@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

As you may have heard [1], Linus isn't planning on opening up a 2.7
tree anytime soon (or perhaps ever).  Instead, the idea is to put
experimental/new stuff in Andrew's mm tree and then trickle them into
Linus' tree, with the responsibility of shipping fully stable kernels
(yeah, right...) left to the distributors.  In other words, things
will continue pretty much the same way they have been for the last
couple of months.

Another change that will be coming down the pipe shortly is that I'll
be working from Switzerland for the next 3 months (should be back at
the beginning of November).  While nothing changes as far as my
employment status/responsibilites/etc. are concerned, this does mean
that I'll be 100+ ms away from my normal build/test-machines, which will
make it more difficult to do the day-to-day kernel maintenance.

Given these changes, I asked Tony Luck to take on the hat as the ia64
2.6 maintainer starting this week (as you may recall, we originally
planned to do this once 2.7 opened).  I'm confident Tony will do a
fine job but he won't be alone anyhow---I do plan to stay around and
at some point down the road, we'll probably want to open an
experimental/unstable tree, perhaps something that tracks Andrew's mm
tree with additional, more experimental patches (along the lines of
Chris Lameter's timer patches; or more fundamental stuff, such as
super-page support).  For the time being, I don't believe there is an
urgent need for an experimental tree, but if you think otherwise, do
let me know.

In the meantime, please welcome Tony Luck in his new role and please
be kind to him as he's navigating through the bitkeeper
gauntlet... ;-)

	--david

[1] http://kerneltrap.org/node/view/3513
