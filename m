From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 18 Dec 2003 19:28:58 +0000
Subject: Re: IA64 test report: 2.4.24-pre1/tiger 2003-12-18: 9/9 pass
Message-Id: <marc-linux-ia64-107177617220781@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107174041010580@msgid-missing>
In-Reply-To: <marc-linux-ia64-107174041010580@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 18 December 2003 2:37 am, Yu, Luming wrote:
> 3.Unable to handle kernel NULL pointer dereferencehwclock[43]: Oops 8804682956800
> Pid: 43, CPU 2, comm:              hwclock

This was caused by a screwed up EFI RTC patch.  I sent Marcelo
a fix yesterday, and he applied it.  Here's the patch, in case
you're interested:

=== drivers/char/efirtc.c 1.6 vs edited ==--- 1.6/drivers/char/efirtc.c	Fri Oct 24 04:35:10 2003
+++ edited/drivers/char/efirtc.c	Wed Dec 17 14:33:08 2003
@@ -118,7 +118,7 @@
 static void
 convert_from_efi_time(efi_time_t *eft, struct rtc_time *wtime)
 {
-	memset(&wtime, 0, sizeof(struct rtc_time));
+	memset(wtime, 0, sizeof(struct rtc_time));
 	wtime->tm_sec  = eft->second;
 	wtime->tm_min  = eft->minute;
 	wtime->tm_hour = eft->hour;

