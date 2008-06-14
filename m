From: Jack Steiner <steiner@sgi.com>
Date: Sat, 14 Jun 2008 12:57:25 +0000
Subject: [PATCH] - Fix CONFIG_IA64_SGI_UV build error
Message-Id: <20080614125724.GA3133@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix build error in CONFIG_IA64_SGI_UV config. (GENERIC builds
are ok).

Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/ia64/Makefile              |    1 +
 arch/ia64/uv/kernel/setup.c     |   12 ++++++++++++
 include/asm-ia64/sn/simulator.h |    7 ++++++-
 3 files changed, 19 insertions(+), 1 deletion(-)

Index: linux/arch/ia64/Makefile
=================================--- linux.orig/arch/ia64/Makefile	2008-06-14 07:14:54.237305605 -0500
+++ linux/arch/ia64/Makefile	2008-06-14 07:16:06.838303636 -0500
@@ -57,6 +57,7 @@ core-$(CONFIG_IA64_GENERIC) 	+= arch/ia6
 core-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/dig/
 core-$(CONFIG_IA64_HP_ZX1_SWIOTLB) += arch/ia64/dig/
 core-$(CONFIG_IA64_SGI_SN2)	+= arch/ia64/sn/
+core-$(CONFIG_IA64_SGI_UV)	+= arch/ia64/uv/
 core-$(CONFIG_KVM) 		+= arch/ia64/kvm/
 
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
Index: linux/arch/ia64/uv/kernel/setup.c
=================================--- linux.orig/arch/ia64/uv/kernel/setup.c	2008-06-14 07:14:54.241306101 -0500
+++ linux/arch/ia64/uv/kernel/setup.c	2008-06-14 07:16:06.850305123 -0500
@@ -17,6 +17,9 @@
 DEFINE_PER_CPU(struct uv_hub_info_s, __uv_hub_info);
 EXPORT_PER_CPU_SYMBOL_GPL(__uv_hub_info);
 
+#ifdef CONFIG_IA64_SGI_UV
+int sn_prom_type;
+#endif
 
 struct redir_addr {
 	unsigned long redirect;
@@ -64,6 +67,15 @@ void __init uv_setup(char **cmdline_p)
 		m_n_config.s.m_skt = 37;
 		m_n_config.s.n_skt = 0;
 		mmr_base = 0;
+#if 0
+		/* Need BIOS calls - TDB */
+		if (!ia64_sn_is_fake_prom())
+			sn_prom_type = 1;
+		else
+#endif
+			sn_prom_type = 2;
+		printk(KERN_INFO "Running on medusa with %s PROM\n",
+					(sn_prom_type = 1) ? "real" : "fake");
 	} else {
 		get_lowmem_redirect(&lowmem_redir_base, &lowmem_redir_size);
 		node_id.v = uv_read_local_mmr(UVH_NODE_ID);
Index: linux/include/asm-ia64/sn/simulator.h
=================================--- linux.orig/include/asm-ia64/sn/simulator.h	2008-06-14 07:06:19.000000000 -0500
+++ linux/include/asm-ia64/sn/simulator.h	2008-06-14 07:20:24.730269232 -0500
@@ -8,7 +8,7 @@
 #ifndef _ASM_IA64_SN_SIMULATOR_H
 #define _ASM_IA64_SN_SIMULATOR_H
 
-
+#if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_SGI_SN2) || defined(CONFIG_IA64_SGI_UV)
 #define SNMAGIC 0xaeeeeeee8badbeefL
 #define IS_MEDUSA()			({long sn; asm("mov %0=cpuid[%1]" : "=r"(sn) : "r"(2)); sn = SNMAGIC;})
 
@@ -16,5 +16,10 @@
 #define IS_RUNNING_ON_SIMULATOR()	(sn_prom_type)
 #define IS_RUNNING_ON_FAKE_PROM()	(sn_prom_type = 2)
 extern int sn_prom_type;		/* 0=hardware, 1=medusa/realprom, 2=medusa/fakeprom */
+#else
+#define IS_MEDUSA()			0
+#define SIMULATOR_SLEEP()
+#define IS_RUNNING_ON_SIMULATOR()	0
+#endif
 
 #endif /* _ASM_IA64_SN_SIMULATOR_H */
