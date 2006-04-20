From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date: Thu, 20 Apr 2006 09:49:41 +0000
Subject: [PATCH 1/2] eliminate compile time warnings
Message-Id: <87ejzs37be.wl%takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a trivial patch to remove following compile time warning:

(snip)
arch/ia64/ia32/../../../fs/binfmt_elf.c:508: warning: 'randomize_stack_top' defined but not used
(snip)

Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

---
 arch/ia64/ia32/binfmt_elf32.c |    3 +++
 1 files changed, 3 insertions(+)

Index: linux-2.6.17-rc2/arch/ia64/ia32/binfmt_elf32.c
=================================--- linux-2.6.17-rc2.orig/arch/ia64/ia32/binfmt_elf32.c	2006-03-20 14:53:29.000000000 +0900
+++ linux-2.6.17-rc2/arch/ia64/ia32/binfmt_elf32.c	2006-04-20 11:35:36.000000000 +0900
@@ -35,6 +35,9 @@ extern void ia64_elf32_init (struct pt_r
 
 static void elf32_set_personality (void);
 
+static unsigned long __attribute ((unused))
+randomize_stack_top(unsigned long stack_top);
+
 #define setup_arg_pages(bprm,tos,exec)		ia32_setup_arg_pages(bprm,exec)
 #define elf_map				elf32_map
