From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 25 Mar 2005 20:27:04 +0000
Subject: Re: [patch 2.6.11] __copy_user breaks on unaligned src
Message-Id: <16964.29720.937091.330552@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12404.1111129477@kao2.melbourne.sgi.com>
In-Reply-To: <12404.1111129477@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 24 Mar 2005 23:59:41 -0800, David Mosberger <davidm@linux.hpl.hp.com> said:

  David> After some more digging, it appears that we do get a
  David> vhpt-miss fault first and for some reason, that handler
  David> triggers a (nested) general exception fault with
  David> ISR.code7:4}=3 (IA-64 Reserved Register/Field fault,
  David> Unimplemented Data Address fault".  Not sure yet what
  David> triggers the nested fault.

Well, this turned out to be a bit of a red herring: it was faulting
because the lfetch.fault happened before the Linux page-table-base
register (ar.k7) was initialized.  On the real hardware, ar.k7 was
zero and since the lfetch-triggered fault was to address 0, this
caused the vhpt_miss handler to go down in flames.

The attached patch fixes this problem and the machine now boots fine
using lfetch.fault for prefetch()/prefetchw().

Keith: unfortunately, I doubt this will be of any help in tracking
down your problem.

Tony: this patch is perfectly safe and helps make the kernel more
robust, so I'd recommend to apply it soonish.

Thanks,
	--david

ia64: Initialize ar.k7 to empty_zero_page early on

Without this initialization, early TLB misses to any user-regions will
cause the TLB miss handlers to go down in flames.  Normally, no such
early TLB misses occur, but aggressive use of lfetch.fault can trigger
it easily (e.g., when using lfetch.fault for the
prefetch()/prefetchw() macros we get an early miss for address 0 due
to a prefetch in find_pid()).

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/setup.c 1.90 vs edited ==--- 1.90/arch/ia64/kernel/setup.c	2005-03-23 11:08:32 -08:00
+++ edited/arch/ia64/kernel/setup.c	2005-03-25 12:10:44 -08:00
@@ -711,6 +711,15 @@
 	ia64_set_kr(IA64_KR_FPU_OWNER, 0);
 
 	/*
+	 * Initialize the page-table base register to a global
+	 * directory with all zeroes.  This ensure that we can handle
+	 * TLB-misses to user address-space even before we created the
+	 * first user address-space.  This may happen, e.g., due to
+	 * aggressive use of lfetch.fault.
+	 */
+	ia64_set_kr(IA64_KR_PT_BASE, __pa(ia64_imva(empty_zero_page)));
+
+	/*
 	 * Initialize default control register to defer all speculative faults.  The
 	 * kernel MUST NOT depend on a particular setting of these bits (in other words,
 	 * the kernel must have recovery code for all speculative accesses).  Turn on
