From: Horms <horms@verge.net.au>
Date: Mon, 23 Oct 2006 08:48:45 +0000
Subject: [patch 5/5] Add phys_efi command line option
Message-Id: <20061023090334.909686577@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061006023253.291524000@tabatha.lab.ultramonkey.org>
In-Reply-To: <20061006023253.291524000@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch adds a command line option, phys_efi, which forces
EFI calls to stay in physical mode. This is mainly for the purpose
of being able to test the physical mode code path.

I believe that it may also be needed in order to kexec between
OS/hypervisors with different memory layouts, such as Linux->Xen and vice
versa, which have 0xe000... and 0xf000... as their page offset respecively.
However, I am still working on verifying this.

Signed-Off-By: Simon Horman <horms@verge.net.au>

 Documentation/kernel-parameters.txt |    4 ++++
 arch/ia64/kernel/efi.c              |    9 ++++++++-
 2 files changed, 12 insertions(+), 1 deletion(-)

Index: kexec-ia64-2.6/arch/ia64/kernel/efi.c
=================================--- kexec-ia64-2.6.orig/arch/ia64/kernel/efi.c	2006-10-20 12:58:00.000000000 +0900
+++ kexec-ia64-2.6/arch/ia64/kernel/efi.c	2006-10-20 12:58:00.000000000 +0900
@@ -414,6 +414,7 @@
 	u64 efi_desc_size;
 	char *cp, vendor[100] = "unknown";
 	extern char saved_command_line[];
+	int phys_efi = 0;
 	int i;
 
 	/* it's too early to be able to use the standard kernel command line support... */
@@ -424,6 +425,9 @@
 			max_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
 		} else if (memcmp(cp, "min_addr=", 9) = 0) {
 			min_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
+		} else if (memcmp(cp, "phys_efi", 8) = 0) {
+			phys_efi = 1;
+			cp+=8;
 		} else {
 			while (*cp != ' ' && *cp)
 				++cp;
@@ -527,7 +531,10 @@
 	}
 #endif
 
-	efi_enter_virtual_mode();
+	if (phys_efi)
+		printk("Forcing EFI to stay in physical mode\n");
+	else
+		efi_enter_virtual_mode();
 }
 
 void
Index: kexec-ia64-2.6/Documentation/kernel-parameters.txt
=================================--- kexec-ia64-2.6.orig/Documentation/kernel-parameters.txt	2006-10-20 12:57:20.000000000 +0900
+++ kexec-ia64-2.6/Documentation/kernel-parameters.txt	2006-10-20 12:58:00.000000000 +0900
@@ -1266,6 +1266,10 @@
 	pg.		[PARIDE]
 			See Documentation/paride.txt.
 
+	phys_efi	[IA-64] Force EFI, PAL and SAL calls to be made
+			in physical mode. Otherwise, if possible virtual mode
+			calls are made.
+
 	pirq=		[SMP,APIC] Manual mp-table setup
 			See Documentation/i386/IO-APIC.txt.
 

--

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

