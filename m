From: Jes Sorensen <jes@wildopensource.com>
Date: Mon, 23 Jun 2003 14:15:03 +0000
Subject: [Linux-ia64] 2.5.72 bss initializers
Message-Id: <marc-linux-ia64-105637930631805@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

No need to explicitly zero out global pointers in efi.c and efivars.c

Cheers,
Jes

--- arch/ia64/kernel/efi.c~	Mon Jun 16 21:19:39 2003
+++ arch/ia64/kernel/efi.c	Mon Jun 23 07:08:53 2003
@@ -46,7 +46,7 @@
  * prior to creating their own entries under /proc/efi.
  */
 #ifdef CONFIG_PROC_FS
-struct proc_dir_entry *efi_dir = NULL;
+struct proc_dir_entry *efi_dir;
 #endif
 
 static unsigned long mem_limit = ~0UL;
--- arch/ia64/kernel/efivars.c~	Mon Jun 16 21:20:01 2003
+++ arch/ia64/kernel/efivars.c	Mon Jun 23 07:09:40 2003
@@ -119,7 +119,7 @@
 */
 static spinlock_t efivars_lock = SPIN_LOCK_UNLOCKED;
 static LIST_HEAD(efivar_list);
-static struct proc_dir_entry *efi_vars_dir = NULL;
+static struct proc_dir_entry *efi_vars_dir;
 
 #define efivar_entry(n) list_entry(n, efivar_entry_t, list)
 

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64
