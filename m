From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 18 Jul 2002 20:33:42 +0000
Subject: [Linux-ia64] headsup: MS_SYNC/MS_INVALIDATE mismatch
Message-Id: <marc-linux-ia64-105590701905780@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A bug in the glibc version of the header file /usr/include/bits/mman.h
has been found which has the effect that the values of MS_SYNC and
MS_INVALIDATE are swapped compared to what the kernel expects.  The
correct values are as follows:

#define MS_INVALIDATE   2               /* invalidate the caches */
#define MS_SYNC         4               /* synchronous memory sync */

The glibc maintainer (Uli Drepper) is aware of the problem and future
versions of glibc will be fixed.

This bug was introduced by yours truly back in 1999.  The fact that it
went unnoticed for so long suggests that there don't seem to be too
many applications out there that depend on these values.  Still, my
apologies for any inconvenience this may have caused.

	--david

