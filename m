From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 15 May 2003 03:17:35 +0000
Subject: [Linux-ia64] bk tree at http://lia64.bkbits.net:8080/linux-ia64-2.5
Message-Id: <marc-linux-ia64-105590723705819@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

For those of you eager to try the bk tree: now might be a good time to
try it out.  The current tree Works For Me.

Jes, I applied the gettimeoffset patch, but also consolidated it with
the last_nsec_offset.  It didn't make sense to me to have both of them
in the generic kernel, when they were basically doing the same thing.
I compensated for this change by having the SN2 update/reset_wall_time
hooks call the generic ia64 hooks first.  You may want to retest to
make sure it all works as expected.

Oh, I also measured the effect of the additional sal_platform_features
check in the fast gettimeofday(): the cold cache case is definitely a
bit slower and more variable (as you'd expect), but the warm cache
case continues to run at 130 cycles, which is nice.

	--david

