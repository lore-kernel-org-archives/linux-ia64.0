From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 Nov 2003 02:38:49 +0000
Subject: Re: bk pull on ia64 linux tree
Message-Id: <marc-linux-ia64-106851834432358@msgid-missing>
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

This should fix the PROT_NONE botch, along with a bug that caused
/proc/irq/prof_cpu_mask to output bad info, which could break
user-level tools.

Thanks!

	--david

 arch/ia64/kernel/irq.c     |    2 +-
 include/asm-ia64/pgtable.h |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (03/11/10 1.1359)
   ia64: Fix _PAGE_CHG_MASK so PROT_NONE works again.  Caught by Linus.

<pj@sgi.com> (03/11/10 1.1358)
   [PATCH] ia64: fix bug in prof_cpu_mask_read_proc()
   
   Display of cpumask for /proc/irq/prof_cpu_mask has a botch in the print
   loop - should consume 2 bytes per loop.

