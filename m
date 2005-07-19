From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 19 Jul 2005 01:15:06 +0000
Subject: Fix some warnings when building with gcc 4
Message-Id: <20050719011506.GE20534@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Following are some patches to fix some IA64 specific warnings I am
seeing when building with gcc 4.  I'm pretty sure they can't hurt
people not using gcc 4.

The only IA64 specific one that I still see is

 include/asm/mmu_context.h:67: warning: type qualifiers ignored on
 function return type

This is because mmu_context_t is defined as volatile for a good reason

 /*
  * Type for a context number.  We declare it volatile to ensure
  * proper ordering when it's accessed outside of spinlock'd critical
  * sections (e.g., as done in activate_mm() and init_new_context()).
  */

However, when a function returns a mmu_context_t it ends up with the
qualified return type (which according to this old message
http://gcc.gnu.org/ml/gcc-patches/2000-10/msg00814.html doesn't mean
anything, unless something has changed).  So I'm not sure what the
best solution is for that one.

Thanks,

-i
