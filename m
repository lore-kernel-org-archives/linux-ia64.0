From: Russ Anderson <rja@sgi.com>
Date: Sun, 06 Feb 2005 15:58:01 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <200502061558.j16Fw1qa20144733@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> This patch helps some (all uses of ia64_mca_data in
> mca_asm.S need to deref the pointer to get at the
> actual space, instead of clobbering thigs in the
> percpu area).

That patch does not work on Altix (discontig & SMP).
The system wedges in the MCA code.

The patch (below) helps in that they system gets through the
MCA code and back to the error injection app, but then
the system dies.

I'm confused about how the offsets are now being computed.
Keith's explaination made sense.  How does the current code
get the correct link time offsets?

Keith Owens wrote:
> Russ Anderson <rja@sgi.com> wrote:
> >OK, just to make sure I understand, it is not practical to have ar.k3
> >store a pointer to __per_cpu_start, due to the difficulty computing
> >the offset to per_cpu__cpu_info.  So ar.k3 should point at the
> >the start of per_cpu__cpu_info (the cpuinfo_ia64 structure).
> 
> Right.  We can compute the offset from __per_cpu_start to
> per_cpu__cpu_info, but that offset can only be computed at link time.
> That rules out the use of asm-offsets, asm-offsets.h is built at
> compile time, not link time.  The extra code required to compute the
> offset at link time and apply that offset to ar.k3 to get from
> __per_cpu_start to per_cpu__cpu_info is ugly and is not worth the
> effort.
> 
> Put all the MCA related fields in struct cpuinfo_ia64, point ar.k3 at
> struct cpuinfo_ia64 and we can use compile time offsets for the fields
> that the MCA handler cares about.  We just need to document that all
> MCA related fields must be in struct cpuinfo_ia64 or accessed via a
> pointer that is in struct cpuinfo_ia64.



-----------------------------------------------------
Index: linux/arch/ia64/kernel/mca_asm.S
=================================--- linux.orig/arch/ia64/kernel/mca_asm.S	2005-02-04 09:58:01.241029555 -0600
+++ linux/arch/ia64/kernel/mca_asm.S	2005-02-05 10:11:46.126571337 -0600
@@ -342,10 +342,10 @@
 	// restore the original stack frame here
 	GET_THIS_PADDR(r2, ia64_mca_data)
 	;;
-	add r2 = IA64_MCA_CPU_STACKFRAME_OFFSET, r2
-	;;
 	ld8 r2 = [r2]
 	;;
+	add r2 = IA64_MCA_CPU_STACKFRAME_OFFSET, r2
+	;;
 	movl    r4=IA64_PSR_MC
 	;;
 	rse_return_context(r4,r3,r2)	// switch from interrupt context for RSE
-----------------------------------------------------



-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
