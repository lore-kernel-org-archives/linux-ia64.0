From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 25 Mar 2004 00:11:23 +0000
Subject: Re: hardware random number generator?
Message-Id: <200403241711.23499.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <405F9A2E.8040509@pobox.com>
In-Reply-To: <405F9A2E.8040509@pobox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 24 March 2004 12:23 am, Mallick, Asit K wrote:
> E8870 based McKinley/Madison platforms does have ICH4. It is used to
> provide USB, IDE, On board LAN, LPC, SMBus, etc. funtionality. However,
> the RNG does not work on current E8870 based platforms. Future platforms
> may enable RNG.

The following patch allows hw_random.c to build on ia64.  (The problem
was just that the VIA stuff has i386 assembly in it.  The current code
only probes for VIA on i386 anyway, so this patch just adds more ifdefs
so the VIA code is only built for i386.)

This boots fine on my Tiger, but reading it seems to give all ones,
which I suppose is what you mean about it being broken.

I don't know whether we should
  1) apply this patch, and ignore the fact that you don't
     get random data on current E8870-based platforms,
  2) put in some kind of check for known-buggy hardware (I don't
     know how to do that, of course), or
  3) change Kconfig so we don't offer it for ia64 (though
     we will presumably want to do so for future ia64 platforms).

I guess I vote for (1) at the moment, and if you think we should
be smart about identifying the broken versions of E8870, maybe
you can supply a patch, Asit.

=== drivers/char/hw_random.c 1.13 vs edited ==--- 1.13/drivers/char/hw_random.c	Fri Jan 30 21:25:15 2004
+++ edited/drivers/char/hw_random.c	Wed Mar 24 16:16:21 2004
@@ -92,10 +92,12 @@
 static unsigned int amd_data_present (void);
 static u32 amd_data_read (void);
 
+#ifdef __i386__
 static int __init via_init(struct pci_dev *dev);
 static void via_cleanup(void);
 static unsigned int via_data_present (void);
 static u32 via_data_read (void);
+#endif
 
 struct rng_operations {
 	int (*init) (struct pci_dev *dev);
@@ -137,8 +139,10 @@
 	/* rng_hw_amd */
 	{ amd_init, amd_cleanup, amd_data_present, amd_data_read, 4 },
 
+#ifdef __i386__
 	/* rng_hw_via */
 	{ via_init, via_cleanup, via_data_present, via_data_read, 1 },
+#endif
 };
 
 /*
@@ -341,6 +345,7 @@
 	/* FIXME: twiddle pmio, also? */
 }
 
+#ifdef __i386__
 /***********************************************************************
  *
  * VIA RNG operations
@@ -456,6 +461,7 @@
 {
 	/* do nothing */
 }
+#endif
 
 
 /***********************************************************************
