From: Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>
Date: Tue, 04 Nov 2003 01:43:49 +0000
Subject: Re: percpu data for non-existant cpus
MIME-Version: 1
Content-Type: multipart/mixed; boundary="--Next_Part(Tue_Nov__4_10:43:49_2003_639)--"
Message-Id: <marc-linux-ia64-106791036330723@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106790736528585@msgid-missing>
In-Reply-To: <marc-linux-ia64-106790736528585@msgid-missing>
To: linux-ia64@vger.kernel.org

----Next_Part(Tue_Nov__4_10:43:49_2003_639)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

From: Jack Steiner <steiner@sgi.com>
Subject: percpu data for non-existant cpus
Date: Mon, 3 Nov 2003 18:55:24 -0600

> It was neccessary in 2.4 to allocate cpu_data areas for
> non-existent cpus. I forget where, but some generic
> initialization code expected to be able to reference cpu_data 
> for all cpus up to NR_CPUS.
> 
> Does 2.6 have the same requirement or can I allocate cpu_data
> areas only for cpus that exist or might exist (cpu_possible()).

The current discontig (for both 2.4 & 2.6) only allocate
cpu_data on existing nodes (which means existing cpus
eventually), doesn't it?

We've found wrap_mmu_context() refers to all percpu data
and if the any of the cpu_data is not valid,
it may cause panic.

Attached patches are for 2.4 & 2.6, which are harmless
even when percpu data are allocated for non-existing
cpus.

---
Takayoshi Kochi

----Next_Part(Tue_Nov__4_10:43:49_2003_639)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="wrap_mmu_context-2.4.patch"

--- linux-2.4.22/arch/ia64/mm/tlb.c.orig	Fri Sep 12 09:45:18 2003
+++ linux-2.4.22/arch/ia64/mm/tlb.c	Wed Oct  8 17:56:03 2003
@@ -75,7 +75,7 @@
 	 * and because interrupts are disabled during context switch.
 	 */
 	for (i = 0; i < NR_CPUS; ++i)
-		if (i != smp_processor_id())
+		if (cpu_online(i) && (i != smp_processor_id()))
 			cpu_data(i)->need_tlb_flush = 1;
 	local_flush_tlb_all();
 }

----Next_Part(Tue_Nov__4_10:43:49_2003_639)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="wrap_mmu_context-2.6.patch"

--- linux-2.6.0-test6.orig/arch/ia64/mm/tlb.c	Sun Sep 28 09:50:38 2003
+++ linux-2.6.0-test6/arch/ia64/mm/tlb.c	Wed Oct  8 17:58:42 2003
@@ -77,7 +77,7 @@
 	{
 		int cpu = get_cpu(); /* prevent preemption/migration */
 		for (i = 0; i < NR_CPUS; ++i)
-			if (i != cpu)
+			if (cpu_online(i) && (i != cpu))
 				per_cpu(ia64_need_tlb_flush, i) = 1;
 		put_cpu();
 	}

----Next_Part(Tue_Nov__4_10:43:49_2003_639)----
