From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 26 Aug 2003 18:29:10 +0000
Subject: kernel update (relative to 2.6.0-test4)
Message-Id: <marc-linux-ia64-106192276030286@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest ia64 patch is now available at
ftp://www.kernel.org/pub/linux/kernel/ports/ia64/v2.5/ in
file:

 linux-2.6.0-test4-ia64-030826.diff.gz

Mainly a collection of bug-fixes plus sync'ing with 2.6.0-test4 (e.g.,
fadvise64_64() is now hooked up).  Also, I included a patch by Arun
which makes x86 GDT/LDT accesses work again.  The patch was supposed
to be in Linus' 2.6.0-test4 but got overlooked somehow.

The kernel seems to work fine on various zx1-based machines and the HP
Simulator.  I didn't try Lion/Big Sur but the ACPI bug that was
keeping earlier kernels from working has been folded into the main
tree, so in theory, the kernel should work on those platforms again.

Oh, -test3 had some nasty race conditions in the timer code and that
caused it to crash on MP machines under heavy load.  -test4 seems to
be much better in this regard.

Enjoy,

	--david
