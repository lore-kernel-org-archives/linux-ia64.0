From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Sat, 18 Apr 2009 03:31:41 +0000
Subject: Re: ia64 allmodconfig bustage in 2.6.30-rc2
Message-Id: <20090418033141.GA24626%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090417152551.381bc522.akpm@linux-foundation.org>
In-Reply-To: <20090417152551.381bc522.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 17, 2009 at 04:07:51PM -0700, Luck, Tony wrote:
> > `make allmodconfig'
> > `make vmlinux'
> >
> >  CC      arch/ia64/kernel/asm-offsets.s
> > In file included from include/linux/bitops.h:17,
> >                 from include/linux/kernel.h:15,
> >                 from include/linux/sched.h:52,
> >                 from arch/ia64/kernel/asm-offsets.c:9:
> > /usr/src/devel/arch/ia64/include/asm/bitops.h: In function `set_bit':
> > /usr/src/devel/arch/ia64/include/asm/bitops.h:47: error: implicit declaration of function `BUILD_BUG_ON'
> 
> Line 47 of bitops.h is a CMPXCHG_BUGCHECK() and allmodconfig
> has CONFIG_IA64_DEBUG_CMPXCHG=y, so we pick the debug version
> that uses ia64_getreg(_IA64_REG_IP) to printk a message about
> where we are stuck.
> 
> Now allmodconfig picks CONFIG_PARAVIRT=y ... so this ends up
> taking us to __paravirt_getreg(), which is where the BUILD_BUG_ON()
> gets introduced.  So we need to include <linux/kernel.h> somewhere
> (or somewhere earlier than we currently do) to make this alright.
> 
> But our probem is that kernel.h goes off and includes bitops.h
> long before it defines BUILD_BUG_ON.  Just moving the definition
> of BUILD_BUG_ON up before we #include anything else (ugly) fixes
> this immediate problem ... but then there are lots of other errors from
> asm/bitops.h :-(
> 
> Deleting the two BUILD_BUG_ON instances from paravirt_privop.h does
> get the build up on its feet and running.  But that loses us some
> compile time checking for a coding/usage error.
> 
> Yamahata-san: How important do you think the BUILD_BUG_ON()
> checks are here?  What would the failure look like if we dropped
> them, and at some later time someone coded a call to ia64_getreg
> with a non-constant register number as argument?
> 
> -Tony
> 

Oh, sorry. I think removing it doesn't spoil compile time check
because the error the BUILD_BUG_ON() catches is also caught when
CONFIG_PARAVIRT=n. Here is the patch.

From f8f6a92b7433debdc8e70157ae2d70cbadcdd90b Mon Sep 17 00:00:00 2001
From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Sat, 18 Apr 2009 12:15:23 +0900
Subject: [PATCH] ia64/pv_ops: fix allmodconfig compilation breakage.

This patch fixes the following compilation error caused by recursive
inclusion of kernel.h which defines BUILD_BUG_ON().
In this case, the case it catches will be caught by the case
CONFIG_PARAVIRT=n, so removing it would not hurt compile time check
very much. So fix the breakage by removing it.

  CC      arch/ia64/kernel/asm-offsets.s
In file included from include/linux/bitops.h:17,
                 from include/linux/kernel.h:15,
                 from include/linux/sched.h:52,
                 from arch/ia64/kernel/asm-offsets.c:9:
arch/ia64/include/asm/bitops.h: In function 'set_bit':
arch/ia64/include/asm/bitops.h:47: error: implicit declaration of function 'BUILD_BUG_ON'

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/paravirt_privop.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/include/asm/paravirt_privop.h b/arch/ia64/include/asm/paravirt_privop.h
index 3d29511..8f6cb11 100644
--- a/arch/ia64/include/asm/paravirt_privop.h
+++ b/arch/ia64/include/asm/paravirt_privop.h
@@ -445,7 +445,6 @@ paravirt_set_rr0_to_rr4(unsigned long val0, unsigned long val1,
 		register unsigned long ia64_intri_res asm ("r8");	\
 		register unsigned long __reg asm ("r8") = (reg);	\
 									\
-		BUILD_BUG_ON(!__builtin_constant_p(reg));		\
 		asm volatile (paravirt_alt_bundle(__PARAVIRT_BR,	\
 						  PARAVIRT_TYPE(GETREG) \
 						  + (reg))		\
@@ -464,7 +463,6 @@ paravirt_set_rr0_to_rr4(unsigned long val0, unsigned long val1,
 		register unsigned long ia64_clobber1 asm ("r8");	\
 		register unsigned long ia64_clobber2 asm ("r9");	\
 									\
-		BUILD_BUG_ON(!__builtin_constant_p(reg));		\
 		asm volatile (paravirt_alt_bundle(__PARAVIRT_BR,	\
 						  PARAVIRT_TYPE(SETREG) \
 						  + (reg))		\
-- 
1.6.0.2



-- 
yamahata
