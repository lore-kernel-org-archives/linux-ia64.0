From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 17 Apr 2003 01:50:19 +0000
Subject: [Linux-ia64] updated 2.5.67 patch
Message-Id: <marc-linux-ia64-105590723705528@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

As a convenience, I just posted a new patch on kernel.org
(ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ in file
linux-2.5.67-ia64-030416.diff.gz) which has all the patches that have
accumulated for the 2.5.67 so far.

In particular:

	- the kernel boots on Big Sur again (and Tiger, though I
	  did not verify that myself), along with Ski, and zx1-based
	  platforms
	- x86 shared binaries should work again, thanks to Arun
	- several fixes to improve stability
	- the AGP-support for zx1-based systems should work again
	- read-locks have been cleaned up to avoid switching text-sections
	  within a function (it's not a good thing to do in general and
	  breaks unwinding)

As usual, detailed changelogs are at http://lia64.bkbits.net:8080/to-linus-2.5

Enjoy,

	--david

