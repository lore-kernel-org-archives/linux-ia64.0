From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Fri, 24 Jun 2005 00:28:33 +0000
Subject: [patch][ia64]Refuse kprobe on ivt code
Message-Id: <20050623172832.B26121@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux IA64 <linux-ia64@vger.kernel.org>


Subject: Refuse kprobe insert on IVT code

Not safe to insert kprobes on IVT code.

This patch checks to see if the address on which Kprobes is being
inserted is  in ivt code and if it is in ivt code then
refuse to register kprobe.

Signed-off-by: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>

======================= arch/ia64/kernel/kprobes.c |   13 +++++++++++++
 1 files changed, 13 insertions(+)

Index: linux-2.6.12-mm1/arch/ia64/kernel/kprobes.c
=================================--- linux-2.6.12-mm1.orig/arch/ia64/kernel/kprobes.c
+++ linux-2.6.12-mm1/arch/ia64/kernel/kprobes.c
@@ -263,6 +263,13 @@ static inline void get_kprobe_inst(bundl
 	}
 }
 
+/* Returns non-zero if the PC is in the Interrupt Vector Table */
+static inline int in_ivt_code(unsigned long pc)
+{
+	extern char ia64_ivt[];
+	return (pc >= (u_long)ia64_ivt && pc < (u_long)ia64_ivt+32768);
+}
+
 static int valid_kprobe_addr(int template, int slot, unsigned long addr)
 {
 	if ((slot > 2) || ((bundle_encoding[template][1] = L) && slot > 1)) {
@@ -271,6 +278,12 @@ static int valid_kprobe_addr(int templat
 		return -EINVAL;
 	}
 
+ 	if (in_ivt_code(addr)) {
+ 		printk(KERN_WARNING "Kprobes can't be inserted inside "
+				"IVT code at 0x%lx\n", addr);
+ 		return -EINVAL;
+ 	}
+
 	if (slot = 1) {
 		printk(KERN_WARNING "Inserting kprobes on slot #1 "
 		       "is not supported\n");
