From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 18 Apr 2003 02:02:07 +0000
Subject: [Linux-ia64] USB deadlock in v2.5.67
Message-Id: <marc-linux-ia64-105590723705558@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

So my 2.5.67 kernel was humming along nicely when I got the idea to
unplug a USB keyboard.  Instant deadlock.  The backtrace shows this:

Call Trace:
 [<e0000000048c4260>] hcd_free_dev+0x140/0x240
 [<e0000000048b96e0>] usb_release_dev+0x100/0x140
 [<e000000004743420>] device_release+0x80/0xa0
 [<e000000004697600>] kobject_cleanup+0x100/0x120
 [<e0000000048c34d0>] urb_unlink+0x110/0x1a0
 [<e0000000048c4390>] usb_hcd_giveback_urb+0x30/0x1a0
 [<e0000000048da730>] dl_done_list+0x230/0x2a0
 [<e0000000048dbfd0>] ohci_irq+0x290/0x340
 [<e0000000048c4580>] usb_hcd_irq+0x80/0x100
 [<e000000004414e00>] handle_IRQ_event+0xa0/0x120
 [<e0000000044155e0>] do_IRQ+0x360/0x460
 [<e0000000044174b0>] ia64_handle_irq+0x70/0x140
 [<e000000004411e40>] ia64_leave_kernel+0x0/0x240

<hcd_free_dev+0x140> translates into line 1249 in hcd.c, where it
does:

	spin_lock_irqsave (&hcd_data_lock, flags);

The deadlock is pretty obvious: the same lock has already been
acquired urb_unlink(), 4 levels up in the call-chain.

Anybody have a fix for this?

	--david

