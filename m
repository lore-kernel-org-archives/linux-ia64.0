From: Martin Hicks <mort@wildopensource.com>
Date: Tue, 27 Jan 2004 14:49:17 +0000
Subject: Re: bk pull on ia64 linux tree
Message-Id: <20040127144917.GB24515@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="CUfgB8w4ZwR/yMy5"
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
To: linux-ia64@vger.kernel.org


--CUfgB8w4ZwR/yMy5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline



On Mon, Jan 26, 2004 at 05:37:14PM -0800, David Mosberger wrote:
> Hi Linus,
> 
> please do a
> 
> 	bk pull http://lia64.bkbits.net/to-linus-2.5
> 

Linus, David,

I accidentally left a debug printk in the sn2 timer_interrupt().  Here
is a fix.  I sent an updated patch to David yesterday, but I guess it
didn't make it.

Please apply.

Thanks,
mh

-- 
Martin Hicks                Wild Open Source Inc.
mort@wildopensource.com     613-266-2296

--CUfgB8w4ZwR/yMy5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sn2-timer-interrupt-fixup.diff"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1500  -> 1.1501 
#	arch/ia64/sn/kernel/sn2/timer_interrupt.c	1.1     -> 1.2    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/01/27	mort@green.i.bork.org	1.1501
# Remove debug printk from sn2 timer_interrupt
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/kernel/sn2/timer_interrupt.c b/arch/ia64/sn/kernel/sn2/timer_interrupt.c
--- a/arch/ia64/sn/kernel/sn2/timer_interrupt.c	Tue Jan 27 09:42:06 2004
+++ b/arch/ia64/sn/kernel/sn2/timer_interrupt.c	Tue Jan 27 09:42:06 2004
@@ -48,7 +48,6 @@
 	if (!pda->hb_count--) {
 		pda->hb_count = HZ/2;
 		set_led_bits(pda->hb_state ^= LED_CPU_HEARTBEAT, LED_CPU_HEARTBEAT);
-		printk("Blink\n");
 	}
 
 	if (enable_shub_wars_1_1()) {

--CUfgB8w4ZwR/yMy5--
