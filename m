From: David Brownell <david-b@pacbell.net>
Date: Fri, 18 Apr 2003 15:46:56 +0000
Subject: [Linux-ia64] Re: USB deadlock in v2.5.67
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050809000509060801020803"
Message-Id: <marc-linux-ia64-105590723705566@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705560@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705560@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050809000509060801020803
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Greg KH wrote:
> On Thu, Apr 17, 2003 at 07:02:07PM -0700, David Mosberger wrote:
> 
>><hcd_free_dev+0x140> translates into line 1249 in hcd.c, where it
>>does:
>>
>>	spin_lock_irqsave (&hcd_data_lock, flags);
>>
>>The deadlock is pretty obvious: the same lock has already been
>>acquired urb_unlink(), 4 levels up in the call-chain.
>>
>>Anybody have a fix for this?
> 
> 
> David (Brownell, that is), does this help with the trace I sent you a
> few hours ago?

Seems to be a different problem.  The patch below should
resolve the keyboard problem -- just reorders two lines
so the lock isn't held after the device's records get
deleted, so the order is what it should always have been.

- Dave





--------------050809000509060801020803
Content-Type: text/plain;
 name="hang.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hang.patch"

--- 1.59/drivers/usb/core/hcd.c	Mon Apr 14 14:01:44 2003
+++ edited/drivers/usb/core/hcd.c	Fri Apr 18 08:20:42 2003
@@ -961,8 +961,8 @@
 	spin_lock_irqsave (&hcd_data_lock, flags);
 	list_del_init (&urb->urb_list);
 	dev = urb->dev;
-	usb_put_dev (dev);
 	spin_unlock_irqrestore (&hcd_data_lock, flags);
+	usb_put_dev (dev);
 }
 
 

--------------050809000509060801020803--


