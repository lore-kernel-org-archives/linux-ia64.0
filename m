From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 29 Mar 2001 21:32:22 +0000
Subject: Re: [Linux-ia64] kernel update (third patch relative to 2.4.2)
Message-Id: <marc-linux-ia64-105590693005370@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005356@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005356@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some of you reported that the 2.4.2 based kernels no longer boot
properly because /sbin/init got stuck.  Andreas Schwab found that this
happened only when using a page size smaller than 16KB.  I looked into
this and it turned out to be a nasty initialization ordering problem.
Basically, ia64_mmu_init() ended up using the "unimpl_va_mask" member
in cpu_data[] before it was initialized, which made it appear as if
the CPU implements all 64 virtual address bits.  With a page size of
16KB or bigger, this happened to work mostly OK (though there could
have been corner cases under which this would also have produced
problems), but with a page size of 4 or 8KB, the kernel basically told
the CPU that the entire address space is used for the virtually mapped
page table.  Of course, that doesn't work too well... ;-)

A patch to fix the problem is attached below.  Please let me know how
this goes.  If nothing unexpected crops up, I'd like to update the
patch on ftp.kernel.org on Monday.

	--david

--- arch/ia64/kernel/setup.c~	Wed Mar 28 21:45:13 2001
+++ arch/ia64/kernel/setup.c	Thu Mar 29 13:07:02 2001
@@ -398,6 +398,14 @@
 	pal_vm_info_2_u_t vmi;
 	unsigned int max_ctx;
 
+	/*
+	 * We can't pass "local_cpu_data" do identify_cpu() because we haven't called
+	 * ia64_mmu_init() yet.  And we can't call ia64_mmu_init() first because it
+	 * depends on the data returned by identify_cpu().  We break the dependency by
+	 * accessing cpu_data[] the old way, through identity mapped space.
+	 */
+	identify_cpu(&cpu_data[smp_processor_id()]);
+
 	/* Clear the stack memory reserved for pt_regs: */
 	memset(ia64_task_regs(current), 0, sizeof(struct pt_regs));
 
@@ -416,8 +424,6 @@
 	current->active_mm = &init_mm;
 
 	ia64_mmu_init();
-
-	identify_cpu(local_cpu_data);
 
 #ifdef CONFIG_IA32_SUPPORT
 	/* initialize global ia32 state - CR0 and CR4 */

