From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Nov 2003 07:55:20 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <marc-linux-ia64-106983334020802@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105942507026161@msgid-missing>
In-Reply-To: <marc-linux-ia64-105942507026161@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.  Both patches fix serious
problems.  The first could cause the kernel to crash when dumping core
from an ia64 binary that's using the new system call stubs and the
second fixes a bug that prevented gdb from working properly inside the
kernel's gate DSO.

Thanks much to Rohit Seth for tracking down the coredumping problem!
(Which I would have sworn was due to race condition; boy was I wrong!)

Thanks!

	--david

 arch/ia64/kernel/unwind.c  |    2 +-
 include/asm-ia64/pgtable.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (03/11/25 1.1486)
   ia64: Make core-dumps work even when executing in the gate DSO.
         Tracked down by Rohit Seth.

<davidm@tiger.hpl.hp.com> (03/11/25 1.1485)
   ia64: Correct FIXADDR_USER_END so that single-stepping in the gate DSO works again.

