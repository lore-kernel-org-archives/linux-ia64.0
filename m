From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 10 Jul 2002 04:24:39 +0000
Subject: [Linux-ia64] radeon frame buffer bug?
Message-Id: <marc-linux-ia64-105590701905750@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Normally I don't turn on the frame buffer code, but by coincidence, I
had it turned on today on an Itanium 2 box with a Radeon card.  The
kernel crashed late in the boot when the frame buffer driver was
trying to blink the cursor (I think).  I took a quick look at the code
and it seems to me that the Radeon driver is missing an ioremap().
The patch below isn't quite correct, as the second argument to
ioremap() needs to be the size of the buffer (not sure what it is); of
course, on ia64 the size doesn't really matter due to the identity
mapping that we're using.

Anybody who's more familiar with this code have any comments?

	--david

--- drivers/video/radeonfb.c~	Tue Feb 26 11:38:30 2002
+++ drivers/video/radeonfb.c	Tue Jul  9 19:06:15 2002
@@ -1692,7 +1692,7 @@
                 
         disp->dispsw_data = NULL;
         
-        disp->screen_base = (char*)rinfo->fb_base;
+        disp->screen_base = ioremap(rinfo->fb_base, 0);
         disp->type = FB_TYPE_PACKED_PIXELS;
         disp->type_aux = 0;
         disp->ypanstep = 1;

