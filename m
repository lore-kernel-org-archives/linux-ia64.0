From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 25 Mar 2004 16:15:53 +0000
Subject: Re: [PATCH] Fix uninitialized data in EFI RTC /proc interface
Message-Id: <200403250915.53296.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403250908.25718.bjorn.helgaas@hp.com>
In-Reply-To: <200403250908.25718.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

(Sorry about the malformed patch -- I screwed it up while adding
the text at the top.  Here's a corrected one.)

Please apply the following patch (based on 2.6.5-rc2).

The problem is that we don't clear out the efi_time_t buffer
before asking EFI to fill it in.  EFI doesn't always write the
entire buffer (in particular, the alarm time only supports one
second resolution, so the nanosecond field is often untouched).

The effect is that 'cat /proc/driver/efirtc' shows garbage in
the nanoseconds part of the alarm time, and sometimes artifacts
like bogus alarm date and junk after the actual end of the text.

=== drivers/char/efirtc.c 1.8 vs edited ==--- 1.8/drivers/char/efirtc.c	Mon Jan 19 16:38:04 2004
+++ edited/drivers/char/efirtc.c	Thu Mar 25 08:48:45 2004
@@ -6,13 +6,13 @@
  *
  * Based on skeleton from the drivers/char/rtc.c driver by P. Gortmaker
  *
- * This code provides a architected & portable interface to the real time 
+ * This code provides an architected & portable interface to the real time 
  * clock by using EFI instead of direct bit fiddling. The functionalities are 
  * quite different from the rtc.c driver. The only way to talk to the device 
  * is by using ioctl(). There is a /proc interface which provides the raw 
  * information.
  *
- * Please note that we have kept the API as close as possible from the 
+ * Please note that we have kept the API as close as possible to the 
  * legacy RTC. The standard /sbin/hwclock program should work normally 
  * when used to get/set the time.
  *
@@ -297,7 +297,7 @@
 };
 
 /*
- *	We export RAW EFI information to /proc/efirtc
+ *	We export RAW EFI information to /proc/driver/efirtc
  */
 static int
 efi_rtc_get_status(char *buf)
@@ -307,6 +307,10 @@
 	char		*p = buf;
 	efi_bool_t	enabled, pending;	
 	unsigned long	flags;
+
+	memset(&eft, 0, sizeof(eft));
+	memset(&alm, 0, sizeof(alm));
+	memset(&cap, 0, sizeof(cap));
 
 	spin_lock_irqsave(&efi_rtc_lock, flags);
 
