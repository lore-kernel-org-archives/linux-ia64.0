From: Matt_Domsch@Dell.com
Date: Wed, 11 Jul 2001 17:28:36 +0000
Subject: [Linux-ia64] [PATCH] re-order partition type check
Message-Id: <marc-linux-ia64-105590693005844@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch below re-orders the check for GPT partitions to be ahead of
testing for msdos partitions.  This is to conform with the EFI Spec, and
follows how GNU Parted is also implemented.


--- linux/fs/partitions/check.c~        Tue Jul  3 14:26:04 2001
+++ linux/fs/partitions/check.c Tue Jul  3 14:26:36 2001
@@ -46,6 +46,9 @@
 #ifdef CONFIG_ACORN_PARTITION
        acorn_partition,
 #endif
+#ifdef CONFIG_EFI_PARTITION
+       efi_partition,
+#endif
 #ifdef CONFIG_MSDOS_PARTITION
        msdos_partition,
 #endif
@@ -72,9 +75,6 @@
 #endif
 #ifdef CONFIG_IBM_PARTITION
        ibm_partition,
-#endif
-#ifdef CONFIG_EFI_PARTITION
-       efi_partition,
 #endif
        NULL
 };


Thanks,
Matt
--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!


