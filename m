From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 10 Jul 2002 06:51:16 +0000
Subject: Re: [Linux-ia64] radeon frame buffer bug?
Message-Id: <marc-linux-ia64-105590701905751@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905750@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905750@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 9 Jul 2002 21:24:39 -0700, David Mosberger <davidm@linux.hpl.hp.com> said:

  David> Normally I don't turn on the frame buffer code, but by
  David> coincidence, I had it turned on today on an Itanium 2 box
  David> with a Radeon card.  The kernel crashed late in the boot when
  David> the frame buffer driver was trying to blink the cursor (I
  David> think).  I took a quick look at the code and it seems to me
  David> that the Radeon driver is missing an ioremap().  The patch
  David> below isn't quite correct, as the second argument to
  David> ioremap() needs to be the size of the buffer (not sure what
  David> it is); of course, on ia64 the size doesn't really matter due
  David> to the identity mapping that we're using.

  David> Anybody who's more familiar with this code have any comments?

It turns out the real problem was due to the fact that the return
value from ioremap() got truncated to 32 bits (ouch!).

The patch below should fix that.  It appears that the vodoo frame
buffer code (sstfb.c) has an analogous truncation problem.

The patch below is for 2.4.18, but it seems 2.5 has the same issues.

	--david

--- drivers/video/radeonfb.c~	Tue Jul  9 19:06:15 2002
+++ drivers/video/radeonfb.c	Tue Jul  9 23:36:32 2002
@@ -258,8 +258,8 @@
 	u32 mmio_base_phys;
 	u32 fb_base_phys;
 
-	u32 mmio_base;
-	u32 fb_base;
+	void *mmio_base;
+	void *fb_base;
 
 	struct pci_dev *pdev;
 
@@ -800,8 +800,7 @@
 	}
 
 	/* map the regions */
-	rinfo->mmio_base = (u32) ioremap (rinfo->mmio_base_phys,
-				    		    RADEON_REGSIZE);
+	rinfo->mmio_base = ioremap (rinfo->mmio_base_phys, RADEON_REGSIZE);
 	if (!rinfo->mmio_base) {
 		printk ("radeonfb: cannot map MMIO\n");
 		release_mem_region (rinfo->mmio_base_phys,
@@ -947,8 +946,7 @@
 		}
 	}
 
-	rinfo->fb_base = (u32) ioremap (rinfo->fb_base_phys,
-				  		  rinfo->video_ram);
+	rinfo->fb_base = ioremap (rinfo->fb_base_phys, rinfo->video_ram);
 	if (!rinfo->fb_base) {
 		printk ("radeonfb: cannot map FB\n");
 		iounmap ((void*)rinfo->mmio_base);

