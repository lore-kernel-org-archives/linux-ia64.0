From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 16 Jan 2004 03:24:07 +0000
Subject: kernel update (relative to 2.6.1)
Message-Id: <16391.22871.396667.865727@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

An ia64 kernel patch for 2.6.1 is now available at:

  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.6/

in file linux-2.6.1-ia64-040115.diff.gz.

It's mostly lots of cleanups (including Andreas' EXPORT_SYMBOL cleanups).

One thing that's new is that the "unwind check" test will be run by
default now, so that we don't get lazy and forget about checking for
bad unwind info.  I think it's OK to always run the check now, because
the new python script runs quickly and because it runs correctly even
when cross-compiling from a 32-bit platform.  However, to rule out any
unpleasant surprises, the kernel gets built no matter whether or not
the unwind check finds any errors.  I expect that at some point in the
future, we might change that so that kernel builds fail if the unwind
check fails.  Thus, if you encounter any problems with unwcheck.py,
please let me know.

This kernel has been tested on various Itanium 2 platforms and on the
HP Ski simulator.  YMMV.

Enjoy,

	--david
