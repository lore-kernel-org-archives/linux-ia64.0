From: Arun Sharma <arun.sharma@intel.com>
Date: Wed, 01 Oct 2003 00:01:31 +0000
Subject: Re: [PATCH] disable legacy floppy related ioctl32s
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030408080107070001090406"
Message-Id: <marc-linux-ia64-106496695204846@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106495318021597@msgid-missing>
In-Reply-To: <marc-linux-ia64-106495318021597@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030408080107070001090406
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Arun Sharma wrote:
> http://marc.theaimsgroup.com/?t=106015010700002&r=1&w=2
> 
> depends on ISA || M68K || SPARC64
> 
> seems to be what was suggested in the thread, but I didn't see a patch. 
> I also agree that the check should be in one place (KConfig). Will send 
> a new patch.

Here's the new patch. It should probably go to LKML now.

	-Arun

--------------030408080107070001090406
Content-Type: text/plain;
 name="ioctl32-floppy.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ioctl32-floppy.patch"

Index: linux-2.6/drivers/block/Kconfig
===================================================================
--- linux-2.6/drivers/block/Kconfig	(revision 13274)
+++ linux-2.6/drivers/block/Kconfig	(working copy)
@@ -6,7 +6,7 @@
 
 config BLK_DEV_FD
 	tristate "Normal floppy disk support"
-	depends on !X86_PC9800
+	depends on ISA || M68K || SPARC64
 	---help---
 	  If you want to use the floppy disk drive(s) of your PC under Linux,
 	  say Y. Information about this driver, especially important for IBM
Index: linux-2.6/include/linux/compat_ioctl.h
===================================================================
--- linux-2.6/include/linux/compat_ioctl.h	(revision 13274)
+++ linux-2.6/include/linux/compat_ioctl.h	(working copy)
@@ -68,7 +68,7 @@
 COMPATIBLE_IOCTL(HDIO_DRIVE_CMD)
 COMPATIBLE_IOCTL(HDIO_SET_PIO_MODE)
 COMPATIBLE_IOCTL(HDIO_SET_NICE)
-#ifndef CONFIG_ARCH_S390
+#ifdef CONFIG_BLK_DEV_FD
 /* 0x02 -- Floppy ioctls */
 COMPATIBLE_IOCTL(FDMSGON)
 COMPATIBLE_IOCTL(FDMSGOFF)

--------------030408080107070001090406--

