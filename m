From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 10 Jun 2005 05:31:34 +0000
Subject: updated libunwind patch for v2.6 kernel
Message-Id: <200506100531.j5A5VYSB001927@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

An updated version of the libunwind patch for the 2.6-kernel is now
available at:

 ftp://ftp.hpl.hp.com/pub/linux-ia64/unwind-2.6-050609.diff.gz

The only change is that the libunwind API has been exported to
modules.  The problem I reported earlier with strace'ing an x86 task
apparently had nothing to do with the libunwind changes as it went
away before I even had a chance to investigate.

This patch passes all my testing so far.  The only thing that I
haven't tested (at all) is the oprofile call-stack tracing.  I'd be
interested to hear if/how that works.  (I did drop the old compiler
support there --- I hope nobody uses such old compilers anymore and
the code was just gross; but if we have to, we can resurrect it).

Tony, I know you're in the middle of making the test-2.6 tree work
better for you.  For now, the patch above is relative to Linus 2.6
tree, but if you have no objections, I'd like to feed it into your
test-2.6 as soon as possible (just let me know when you're ready and I
will respin the patch relative to test-2.6).

Thanks,

	--david
