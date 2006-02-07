From: Zou Nan hai <nanhai.zou@intel.com>
Date: Tue, 07 Feb 2006 03:35:46 +0000
Subject: [PATCH]Fix wrong use of memparse in efi.c
Message-Id: <1139283346.8654.17.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The check of (end != cp) after memparse in efi.c looks wrong to me.
The result is that we can't use mem= and max_addr= kernel parameter at
the same time.

The following patch removed the check just like other arches do.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

diff -Nraup a/arch/ia64/kernel/efi.c d/arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c	2006-02-06 08:33:01.000000000 +0800
+++ d/arch/ia64/kernel/efi.c	2006-02-06 11:50:50.000000000 +0800
@@ -384,24 +384,16 @@ efi_init (void)
 	efi_config_table_t *config_tables;
 	efi_char16_t *c16;
 	u64 efi_desc_size;
-	char *cp, *end, vendor[100] = "unknown";
+	char *cp, vendor[100] = "unknown";
 	extern char saved_command_line[];
 	int i;
 
 	/* it's too early to be able to use the standard kernel command line support... */
 	for (cp = saved_command_line; *cp; ) {
 		if (memcmp(cp, "mem=", 4) = 0) {
-			cp += 4;
-			mem_limit = memparse(cp, &end);
-			if (end != cp)
-				break;
-			cp = end;
+			mem_limit = memparse(cp + 4, &cp);
 		} else if (memcmp(cp, "max_addr=", 9) = 0) {
-			cp += 9;
-			max_addr = GRANULEROUNDDOWN(memparse(cp, &end));
-			if (end != cp)
-				break;
-			cp = end;
+			max_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
 		} else {
 			while (*cp != ' ' && *cp)
 				++cp;



