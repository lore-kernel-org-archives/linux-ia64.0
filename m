From: Mike Rapoport <rppt@linux.ibm.com>
Date: Mon, 21 Jan 2019 08:03:49 +0000
Subject: [PATCH v2 02/21] powerpc: use memblock functions returning virtual address
Message-Id: <1548057848-15136-3-git-send-email-rppt@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+d>

From: Christophe Leroy <christophe.leroy@c-s.fr>

Since only the virtual address of allocated blocks is used,
lets use functions returning directly virtual address.

Those functions have the advantage of also zeroing the block.

[ MR:
 - updated error message in alloc_stack() to be more verbose
 - convereted several additional call sites ]

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/powerpc/kernel/dt_cpu_ftrs.c |  3 +--
 arch/powerpc/kernel/irq.c         |  5 -----
 arch/powerpc/kernel/paca.c        |  6 +++++-
 arch/powerpc/kernel/prom.c        |  5 ++++-
 arch/powerpc/kernel/setup_32.c    | 26 ++++++++++++++++----------
 5 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/arch/powerpc/kernel/dt_cpu_ftrs.c b/arch/powerpc/kernel/dt_cpu_ftrs.c
index 8be3721..2554824 100644
--- a/arch/powerpc/kernel/dt_cpu_ftrs.c
+++ b/arch/powerpc/kernel/dt_cpu_ftrs.c
@@ -813,7 +813,6 @@ static int __init process_cpufeatures_node(unsigned long node,
 	int len;
 
 	f = &dt_cpu_features[i];
-	memset(f, 0, sizeof(struct dt_cpu_feature));
 
 	f->node = node;
 
@@ -1008,7 +1007,7 @@ static int __init dt_cpu_ftrs_scan_callback(unsigned long node, const char
 	/* Count and allocate space for cpu features */
 	of_scan_flat_dt_subnodes(node, count_cpufeatures_subnodes,
 						&nr_dt_cpu_features);
-	dt_cpu_features = __va(memblock_phys_alloc(sizeof(struct dt_cpu_feature) * nr_dt_cpu_features, PAGE_SIZE));
+	dt_cpu_features = memblock_alloc(sizeof(struct dt_cpu_feature) * nr_dt_cpu_features, PAGE_SIZE);
 
 	cpufeatures_setup_start(isa);
 
diff --git a/arch/powerpc/kernel/irq.c b/arch/powerpc/kernel/irq.c
index 916ddc4..4a44bc3 100644
--- a/arch/powerpc/kernel/irq.c
+++ b/arch/powerpc/kernel/irq.c
@@ -725,18 +725,15 @@ void exc_lvl_ctx_init(void)
 #endif
 #endif
 
-		memset((void *)critirq_ctx[cpu_nr], 0, THREAD_SIZE);
 		tp = critirq_ctx[cpu_nr];
 		tp->cpu = cpu_nr;
 		tp->preempt_count = 0;
 
 #ifdef CONFIG_BOOKE
-		memset((void *)dbgirq_ctx[cpu_nr], 0, THREAD_SIZE);
 		tp = dbgirq_ctx[cpu_nr];
 		tp->cpu = cpu_nr;
 		tp->preempt_count = 0;
 
-		memset((void *)mcheckirq_ctx[cpu_nr], 0, THREAD_SIZE);
 		tp = mcheckirq_ctx[cpu_nr];
 		tp->cpu = cpu_nr;
 		tp->preempt_count = HARDIRQ_OFFSET;
@@ -754,12 +751,10 @@ void irq_ctx_init(void)
 	int i;
 
 	for_each_possible_cpu(i) {
-		memset((void *)softirq_ctx[i], 0, THREAD_SIZE);
 		tp = softirq_ctx[i];
 		tp->cpu = i;
 		klp_init_thread_info(tp);
 
-		memset((void *)hardirq_ctx[i], 0, THREAD_SIZE);
 		tp = hardirq_ctx[i];
 		tp->cpu = i;
 		klp_init_thread_info(tp);
diff --git a/arch/powerpc/kernel/paca.c b/arch/powerpc/kernel/paca.c
index 8c890c6..e7382ab 100644
--- a/arch/powerpc/kernel/paca.c
+++ b/arch/powerpc/kernel/paca.c
@@ -196,7 +196,11 @@ void __init allocate_paca_ptrs(void)
 	paca_nr_cpu_ids = nr_cpu_ids;
 
 	paca_ptrs_size = sizeof(struct paca_struct *) * nr_cpu_ids;
-	paca_ptrs = __va(memblock_phys_alloc(paca_ptrs_size, SMP_CACHE_BYTES));
+	paca_ptrs = memblock_alloc_raw(paca_ptrs_size, SMP_CACHE_BYTES);
+	if (!paca_ptrs)
+		panic("Failed to allocate %d bytes for paca pointers\n",
+		      paca_ptrs_size);
+
 	memset(paca_ptrs, 0x88, paca_ptrs_size);
 }
 
diff --git a/arch/powerpc/kernel/prom.c b/arch/powerpc/kernel/prom.c
index e97aaf2..c0ed4fa 100644
--- a/arch/powerpc/kernel/prom.c
+++ b/arch/powerpc/kernel/prom.c
@@ -127,7 +127,10 @@ static void __init move_device_tree(void)
 	if ((memory_limit && (start + size) > PHYSICAL_START + memory_limit) ||
 	    !memblock_is_memory(start + size - 1) ||
 	    overlaps_crashkernel(start, size) || overlaps_initrd(start, size)) {
-		p = __va(memblock_phys_alloc(size, PAGE_SIZE));
+		p = memblock_alloc_raw(size, PAGE_SIZE);
+		if (!p)
+			panic("Failed to allocate %lu bytes to move device tree\n",
+			      size);
 		memcpy(p, initial_boot_params, size);
 		initial_boot_params = p;
 		DBG("Moved device tree to 0x%px\n", p);
diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index 947f904..1f0b762 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -196,6 +196,17 @@ static int __init ppc_init(void)
 }
 arch_initcall(ppc_init);
 
+static void *__init alloc_stack(void)
+{
+	void *ptr = memblock_alloc(THREAD_SIZE, THREAD_SIZE);
+
+	if (!ptr)
+		panic("cannot allocate %d bytes for stack at %pS\n",
+		      THREAD_SIZE, (void *)_RET_IP_);
+
+	return ptr;
+}
+
 void __init irqstack_early_init(void)
 {
 	unsigned int i;
@@ -203,10 +214,8 @@ void __init irqstack_early_init(void)
 	/* interrupt stacks must be in lowmem, we get that for free on ppc32
 	 * as the memblock is limited to lowmem by default */
 	for_each_possible_cpu(i) {
-		softirq_ctx[i] = (struct thread_info *)
-			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
-		hardirq_ctx[i] = (struct thread_info *)
-			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
+		softirq_ctx[i] = alloc_stack();
+		hardirq_ctx[i] = alloc_stack();
 	}
 }
 
@@ -224,13 +233,10 @@ void __init exc_lvl_early_init(void)
 		hw_cpu = 0;
 #endif
 
-		critirq_ctx[hw_cpu] = (struct thread_info *)
-			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
+		critirq_ctx[hw_cpu] = alloc_stack();
 #ifdef CONFIG_BOOKE
-		dbgirq_ctx[hw_cpu] = (struct thread_info *)
-			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
-		mcheckirq_ctx[hw_cpu] = (struct thread_info *)
-			__va(memblock_phys_alloc(THREAD_SIZE, THREAD_SIZE));
+		dbgirq_ctx[hw_cpu] = alloc_stack();
+		mcheckirq_ctx[hw_cpu] = alloc_stack();
 #endif
 	}
 }
-- 
2.7.4
