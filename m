From: Matt_Domsch@Dell.com
Date: Wed, 14 Aug 2002 20:33:08 +0000
Subject: RE: [Linux-ia64] move asm-ia64/efi.h to linux/efi.h ?
Message-Id: <marc-linux-ia64-105590701905940@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905936@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905936@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> David, please download and apply
> http://domsch.com/linux/patches/ia64/linux-2.5-efihmove.cset
> a BK patch against Linus' current BK tree, which also applies cleanly
> against your 2.5.30 test patch posted two days ago.  This moves all
> instances of #include <asm{"",-ia64}/efi.h> to <linux/efi.h>.

And, please apply
http://domsch.com/linux/patches/ia64/linux-2.5-efihmove2.cset
which changes the #ifdef _ASM_IA64_EFI_H to _LINUX_EFI_H test.

 efi.h |    6 +++---
 1 files changed, 3 insertions, 3 deletions


diff -Nru a/include/linux/efi.h b/include/linux/efi.h
--- a/include/linux/efi.h	Wed Aug 14 15:30:48 2002
+++ b/include/linux/efi.h	Wed Aug 14 15:30:48 2002
@@ -1,5 +1,5 @@
-#ifndef _ASM_IA64_EFI_H
-#define _ASM_IA64_EFI_H
+#ifndef _LINUX_EFI_H
+#define _LINUX_EFI_H
 
 /*
  * Extensible Firmware Interface
@@ -281,4 +281,4 @@
 extern struct proc_dir_entry *efi_dir;
 #endif
 
-#endif /* _ASM_IA64_EFI_H */
+#endif /* _LINUX_EFI_H */


Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer, Lead Engineer, Architect
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001 and Q1/2002! (IDC May 2002)


