From: "Ahna, Christopher J" <christopher.j.ahna@intel.com>
Date: Mon, 30 Oct 2000 23:41:02 +0000
Subject: RE: [Linux-ia64] Common kernel paging error I get
Message-Id: <marc-linux-ia64-105590678205640@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205637@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205637@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ken,

I saw something like this a lot when I ran my BigSur with 4GB or more
memory.  It turned out that my problem came from some bad memory management
by the USB driver that was messing up other parts of the kernel.  You might
want to try the attached patch (made against test9) and see if it solves
your problem.  By the way, the fix included in the patch appears in the
latest test releases of 2.4.0-test10.  Thanks,

Chris

-----------------------------------------

diff -urN linux-2.4.0-test9-ia64-001004/drivers/usb/hub.c
linux-2.4.0-test9-ia64-001004-patch/drivers/usb/hub.c
--- linux-2.4.0-test9-ia64-001004/drivers/usb/hub.c	Thu Sep 28 13:20:48
2000
+++ linux-2.4.0-test9-ia64-001004-patch/drivers/usb/hub.c	Mon Oct 30
08:26:50 2000
@@ -592,11 +592,6 @@
 			info("USB new device connect on bus%d, assigned
device number %d",
 				dev->bus->busnum, dev->devnum);
 
-		if (portstr)
-			kfree(portstr);
-		if (tempstr)
-			kfree(tempstr);
-
 		/* Run it through the hoops (find a driver, etc) */
 		if (!usb_new_device(dev)) {
 			up(&usb_address0_sem);
@@ -612,6 +607,12 @@
 
 	hub->children[port] = NULL;
 	usb_hub_port_disable(hub, port);
+
+	if (portstr)
+		kfree(portstr);
+	if (tempstr)
+		kfree(tempstr);
+
 	up(&usb_address0_sem);
 }
 

-----Original Message-----
From: Broadfoot, KenX [mailto:kenx.broadfoot@intel.com]
Sent: Friday, October 27, 2000 9:26 AM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] Common kernel paging error I get



Just wondering if you all see this error often:

Unable to handle kernel paging request at virtual address 0000000000000008

I am using 2.4.0-test9 patched + kdb

When this happens I can't even get into the debugger.

This is on a Quad Lion with 2 gigs of Ram

I see this mostly when running fairly heavy network traffic.


If anyone is familiar with this and has found a way to minimize it, or can
explain what it is to me I would appreciate it.

--ken broadfoot


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


