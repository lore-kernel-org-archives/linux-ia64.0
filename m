From: Richard Hirst <rhirst@linuxcare.com>
Date: Wed, 19 Sep 2001 13:35:24 +0000
Subject: Re: [Linux-ia64] AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805225@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805137@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805137@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 07, 2001 at 10:49:07AM -0700, KOCHI Takayoshi wrote:
> Recently I noticed
> 
> keyboard: Timeout - AT keyboard not present?
> 
> message appears when the kernel tries to control keyboard LEDs
> (i.e. CAPS, NumLock, ScrLock).
> I don't see any symptoms in X environment, this is only at
> VGA console.  I remember this was the behavior of ia64 linux of
> very early days, but fixed at some point.
> 
> Does someone have ideas?

The following patch fixes this for me.  It seems that after the SET_LEDS
command is written, the keyboard sets it's status bit to say the acknowledge
is available, but never generates an interrupt.  Or maybe it does
generate the interrupt and somehow it gets cleared without the keyboard
driver being called.

Richard


--- linux.ori/drivers/char/pc_keyb.c	Tue Aug 14 23:49:50 2001
+++ build-itanium/drivers/char/pc_keyb.c	Wed Sep 19 15:18:14 2001
@@ -512,6 +512,19 @@
 		reply_expected = 1;
 		kbd_write_output_w(data);
 		for (;;) {
+#ifdef __ia64__
+			/* On my ia64 box, at least, we don't always get an int
+			 * from the k/b when the acknowledge is available, so
+			 * do a manual status check.  Interrupts are enabled
+			 * (jiffies changes, at least).
+			 * Richard Hirst <rhirst@linuxcare.com>
+			 */
+			unsigned long flags;
+
+			spin_lock_irqsave(&kbd_controller_lock, flags);
+			handle_kbd_event();
+			spin_unlock_irqrestore(&kbd_controller_lock, flags);
+#endif
 			if (acknowledge)
 				return 1;
 			if (resend)

