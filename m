From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Fri, 22 Aug 2003 21:57:02 +0000
Subject: Re: build problems/questions (2.6.0-test3)
Message-Id: <marc-linux-ia64-106158991021209@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106151574613417@msgid-missing>
In-Reply-To: <marc-linux-ia64-106151574613417@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 22 Aug 2003 03:25:51 +0100 Matthew Wilcox <willy@debian.org> wrote:

| On Thu, Aug 21, 2003 at 06:28:50PM -0700, Randy.Dunlap wrote:
| > I'm seeing some build problems and want to see if they are just my
| > problems.  Shoule these build OK on ia64 or are they all just
| > dont-cares for ia64?
| > 
| > 1.  driver/block/floppy.c
| 
| Don't-care.  Should be made unselectable in Kconfig.  No ia64 boxes have
| shipped with that kind of floppy drive (ide-floppy on the first boxes).
| 
| > 2.  drivers/char/nvram.c ?? (x86-ism)
| 
| I doubt anyone put an mc146818rtc chip in an ia64 box.
| 
| > 3.  drivers/char/hangcheck.c ?
| 
| Do you mean drivers/char/hangcheck-timer.c?  This looks x86-specific to me,
| monotonic_clock() is in arch/i386 and arch/x86_64 only.
| 
| > 4.  ISA PNP support?
| 
| Definitely no ISA on these boxes.  Shouldn't ISAPNP depend on ISA in Kconfig?

Will wait for Adam's comments on PNP.

Here's a Kconfig patch for #1-3 (for 2.6.0-test3).

David, do you want to merge it, or want me to send to lkml for
more comments?

--
~Randy

patch_name:	it_configs.patch
patch_version:	2003-08-22.11:49:52
author:		Randy.Dunlap <rddunlap@osdl.org>
description:	restrict some config options on IA64
product:	Linux
product_versions: 260-test3
diffstat:	 drivers/block/Kconfig |    2 +-
 drivers/char/Kconfig  |    2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)


diff -Naur ./drivers/char/Kconfig~itcfg ./drivers/char/Kconfig
--- ./drivers/char/Kconfig~itcfg	Fri Aug  8 21:31:41 2003
+++ ./drivers/char/Kconfig	Fri Aug 22 11:49:00 2003
@@ -744,6 +744,7 @@
 
 config NVRAM
 	tristate "/dev/nvram support"
+	depends on !IA64
 	---help---
 	  If you say Y here and create a character special file /dev/nvram
 	  with major number 10 and minor number 144 using mknod ("man mknod"),
@@ -1000,6 +1001,7 @@
 
 config HANGCHECK_TIMER
 	tristate "Hangcheck timer"
+	depends on X86
 	help
 	  The hangcheck-timer module detects when the system has gone
 	  out to lunch past a certain margin.  It can reboot the system
diff -Naur ./drivers/block/Kconfig~itcfg ./drivers/block/Kconfig
--- ./drivers/block/Kconfig~itcfg	Fri Aug  8 21:33:53 2003
+++ ./drivers/block/Kconfig	Thu Aug 21 22:08:56 2003
@@ -6,7 +6,7 @@
 
 config BLK_DEV_FD
 	tristate "Normal floppy disk support"
-	depends on !X86_PC9800
+	depends on !X86_PC9800 && !IA64
 	---help---
 	  If you want to use the floppy disk drive(s) of your PC under Linux,
 	  say Y. Information about this driver, especially important for IBM
