From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 19 Aug 2003 23:49:53 +0000
Subject: bogus barriers in sym53c8xx_2?
Message-Id: <marc-linux-ia64-106133886310517@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In drivers/scsi/sym53c8xx_2/sym_misc.h we find:

#elif	defined	__ia64__
#define __READ_BARRIER()	__asm__ volatile("mf.a; mf" : : : "memory")
#define __WRITE_BARRIER()	__asm__ volatile("mf.a; mf" : : : "memory")

based on the comments and the other implementations, these barriers
are bogus and the "mf.a" should be dropped.

Anyone know who wrote this code originally and why the mf.a was added?

mf.a is very slow and should be avoided except were truly needed.

	--david
