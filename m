From: Matthew Wilcox <willy@fc.hp.com>
Date: Wed, 12 Jun 2002 16:53:24 +0000
Subject: [Linux-ia64] Re: [PATCH] random ia64 acpi fixes
Message-Id: <marc-linux-ia64-105590701905667@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Alex pointed out I hadn't actually included the GSI infrastructure in my
last patch, so here it is.  It's all his work, I'm just posting it.

diff -urNX ../dontdiff linux-ia64/arch/ia64/kernel/ia64_ksyms.c linux-generic/arch/ia64/kernel/ia64_ksyms.c
--- linux-ia64/arch/ia64/kernel/ia64_ksyms.c	Sat May 18 11:58:43 2002
+++ linux-generic/arch/ia64/kernel/ia64_ksyms.c	Wed Jun 12 10:43:10 2002
@@ -28,6 +28,7 @@
 
 #include <linux/irq.h>
 EXPORT_SYMBOL(isa_irq_to_vector_map);
+EXPORT_SYMBOL(gsi_to_vector_map);
 EXPORT_SYMBOL(enable_irq);
 EXPORT_SYMBOL(disable_irq);
 EXPORT_SYMBOL(disable_irq_nosync);
diff -urNX ../dontdiff linux-ia64/arch/ia64/kernel/iosapic.c linux-generic/arch/ia64/kernel/iosapic.c
--- linux-ia64/arch/ia64/kernel/iosapic.c	Sat May 18 11:58:43 2002
+++ linux-generic/arch/ia64/kernel/iosapic.c	Wed Jun 12 10:43:11 2002
@@ -421,6 +421,7 @@
 	irq_desc_t *idesc;
 	struct hw_interrupt_type *irq_type;
 
+	gsi_to_vector(global_vector) = vector;
 	iosapic_irq[vector].pin	= pin;
 	iosapic_irq[vector].polarity = polarity ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW;
 	iosapic_irq[vector].dmode    = delivery;
diff -urNX ../dontdiff linux-ia64/arch/ia64/kernel/irq_ia64.c linux-generic/arch/ia64/kernel/irq_ia64.c
--- linux-ia64/arch/ia64/kernel/irq_ia64.c	Fri Jan 25 13:11:06 2002
+++ linux-generic/arch/ia64/kernel/irq_ia64.c	Wed Jun 12 10:43:11 2002
@@ -50,6 +50,11 @@
 	0x28, 0x27, 0x26, 0x25, 0x24, 0x23, 0x22, 0x21
 };
 
+/*
+ * GSI to IA-64 vector translation table.
+ */
+__u8 gsi_to_vector_map[255] = { [0 ... 254] = {0x0}};
+
 int
 ia64_alloc_irq (void)
 {
diff -urNX ../dontdiff linux-ia64/include/asm-ia64/hw_irq.h linux-generic/include/asm-ia64/hw_irq.h
--- linux-ia64/include/asm-ia64/hw_irq.h	Sat May 18 11:59:02 2002
+++ linux-generic/include/asm-ia64/hw_irq.h	Wed Jun 12 10:43:14 2002
@@ -67,6 +67,8 @@
 
 extern __u8 isa_irq_to_vector_map[16];
 #define isa_irq_to_vector(x)	isa_irq_to_vector_map[(x)]
+extern __u8 gsi_to_vector_map[255];
+#define gsi_to_vector(x)	gsi_to_vector_map[(x)]
 
 extern unsigned long ipi_base_addr;
 

-- 
It's always legal to use Linux (TM) systems
http://www.gnu.org/philosophy/why-free.html

