From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 12 Mar 2006 17:08:26 +0000
Subject: [patch 4/6] add init declaration - gate page functions
Message-Id: <200603121708.k2CH8Og10239@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add init declaration to bunch of patch functions and gate
page setup function.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./arch/ia64/kernel/patch.c.orig	2006-03-12 01:31:29.517203176 -0800
+++ ./arch/ia64/kernel/patch.c	2006-03-12 01:35:25.993762779 -0800
@@ -115,7 +115,7 @@ ia64_patch_vtop (unsigned long start, un
 	ia64_srlz_i();
 }
 
-void
+void __init
 ia64_patch_mckinley_e9 (unsigned long start, unsigned long end)
 {
 	static int first_time = 1;
@@ -149,7 +149,7 @@ ia64_patch_mckinley_e9 (unsigned long st
 	ia64_srlz_i();
 }
 
-static void
+static void __init
 patch_fsyscall_table (unsigned long start, unsigned long end)
 {
 	extern unsigned long fsyscall_table[NR_syscalls];
@@ -166,7 +166,7 @@ patch_fsyscall_table (unsigned long star
 	ia64_srlz_i();
 }
 
-static void
+static void __init
 patch_brl_fsys_bubble_down (unsigned long start, unsigned long end)
 {
 	extern char fsys_bubble_down[];
@@ -184,7 +184,7 @@ patch_brl_fsys_bubble_down (unsigned lon
 	ia64_srlz_i();
 }
 
-void
+void __init
 ia64_patch_gate (void)
 {
 #	define START(name)	((unsigned long) __start_gate_##name##_patchlist)
--- ./arch/ia64/mm/init.c.orig	2006-03-12 01:27:43.333612197 -0800
+++ ./arch/ia64/mm/init.c	2006-03-12 01:28:06.588494724 -0800
@@ -294,7 +294,7 @@ put_kernel_page (struct page *page, unsi
 	return page;
 }
 
-static void
+static void __init
 setup_gate (void)
 {
 	struct page *page;



