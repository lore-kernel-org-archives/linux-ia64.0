From: Keith Owens <kaos@sgi.com>
Date: Sun, 22 Feb 2004 14:08:30 +0000
Subject: Re: Oops in pdflush
Message-Id: <23648.1077458910@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 22 Feb 2004 14:58:34 +0100, 
Andreas Schwab <schwab@suse.de> wrote:
>[2]kdb> bt
>Stack traceback for pid 21693
>0xe00000002faf0000    21693        1  1    2   R  0xe00000002faf04b0 *pdflush
>0xa0000001003ff290 kdba_main_loop+0x150
>        args (0x5, 0x5, 0x20000000030, 0x4, 0xe00000002faf6640)
>        kernel 0xa0000001003ff140 0xa0000001003ff2c0
>0xa000000100283e60 kdb+0x820
>        args (0x5, 0x20000000030, 0xe00000002faf6640, 0xa00000010082bbd0, 0xa000000100887a84)
>        kernel 0xa000000100283640 0xa000000100284bc0
>0xa0000001000393c0 die+0x1e0
>        args (0xe00000002faf64b0, 0xe00000002faf6640, 0x20000000030, 0xa00000010071fa80, 0xa000000100039570)
>        kernel 0xa0000001000391e0 0xa000000100039400
>0xa000000100039570 ia64_fault+0x110
>        args (0x18, 0x20000000030, 0xe000000004c86b60, 0x3, 0xe00000002faf6640)
>        kernel 0xa000000100039460 0xa00000010003a4e0
>0xa00000010000d640 ia64_leave_kernel
>        args (0x18, 0x20000000030, 0xe000000004c86b60, 0x3, 0xe00000002faf6640)
>        kernel 0xa00000010000d640 0xa00000010000d8a0
>0xe00000002faf5f00 - No name.  May be an area that has no unwind data

Which makes it a general unwind problem.  Apply this patch to turn on
unwind debugging when in kdb.

Index: 25.2/arch/ia64/kernel/unwind.c
--- 25.2/arch/ia64/kernel/unwind.c Wed, 11 Feb 2004 11:17:55 +1100 kaos (linux-2.4/r/c/42_unwind.c 1.1.2.1.1.2.3.1.1.1.1.3.1.1.1.2 644)
+++ 25.2(w)/arch/ia64/kernel/unwind.c Mon, 23 Feb 2004 01:05:02 +1100 kaos (linux-2.4/r/c/42_unwind.c 1.1.2.1.1.2.3.1.1.1.1.3.1.1.1.2 644)
@@ -56,11 +56,12 @@
 
 #define UNW_STATS	0	/* WARNING: this disabled interrupts for long time-spans!! */
 
+#define UNW_DEBUG 6
 #ifdef UNW_DEBUG
   static unsigned int unw_debug_level = UNW_DEBUG;
 #  ifdef CONFIG_KDB
 #    include <linux/kdb.h>
-#    define UNW_DEBUG_ON(n)	(unw_debug_level >= n && !KDB_IS_RUNNING())
+#    define UNW_DEBUG_ON(n)	(unw_debug_level >= n && KDB_IS_RUNNING())
 #    define UNW_DPRINT(n, ...)	if (UNW_DEBUG_ON(n)) kdb_printf(__VA_ARGS__)
 #  else	/* !CONFIG_KDB */
 #    define UNW_DEBUG_ON(n)	unw_debug_level >= n


When pdflush drops into kdb, type these commands.  I assume that you
can capture the output on a serial console.

set LINES 2000
set BTSP 1
bt

