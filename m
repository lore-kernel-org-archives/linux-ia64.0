From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 05 Oct 2004 11:50:17 +0000
Subject: minor sparse cleanups
Message-Id: <16738.35449.632596.389132@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Hopefully the last sparse patch for the time being.

Thanks,

	--david

Here are three more sparse-triggered fixes which didn't fit anywhere
else.  The first one gets rid of some quoting in palinfo.c which
sparse doesn't like.  This used to be necessary because GCC would
otherwise warn about an unknown trigraph.  That's not a problem
anymore since the kernel is now being compiled with -Wno-trigraphs.
The efirtc.c patch is mostly sparse-annotations but also cleans up
trailing whitespace.  Finally, the bitfields in rwlock_t are changed
to be explicitly "unsigned" to avoid a warning from sparse (it doesn't
like 1-bit signed bitfields in particular).

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

 arch/ia64/kernel/palinfo.c  |    2 +-
 drivers/char/efirtc.c       |   19 +++++++++++--------
 include/asm-ia64/spinlock.h |    4 ++--
 3 files changed, 14 insertions(+), 11 deletions(-)

=== arch/ia64/kernel/palinfo.c 1.17 vs edited ==--- 1.17/arch/ia64/kernel/palinfo.c	2004-08-30 15:13:15 -07:00
+++ edited/arch/ia64/kernel/palinfo.c	2004-10-04 01:02:21 -07:00
@@ -446,7 +446,7 @@
 		     "RSE stacked physical registers   : %ld\n"
 		     "RSE load/store hints             : %ld (%s)\n",
 		     phys_stacked, hints.ph_data,
-		     hints.ph_data < RSE_HINTS_COUNT ? rse_hints[hints.ph_data]: "(\?\?)");
+		     hints.ph_data < RSE_HINTS_COUNT ? rse_hints[hints.ph_data]: "(??)");
 
 	if (ia64_pal_debug_info(&iregs, &dregs))
 		return 0;
=== drivers/char/efirtc.c 1.9 vs edited ==--- 1.9/drivers/char/efirtc.c	2004-03-27 03:43:20 -08:00
+++ edited/drivers/char/efirtc.c	2004-10-04 09:33:43 -07:00
@@ -155,7 +155,7 @@
 	efi_time_t	eft;
 	efi_time_cap_t	cap;
 	struct rtc_time	wtime;
-	struct rtc_wkalrm *ewp;
+	struct rtc_wkalrm __user *ewp;
 	unsigned char	enabled, pending;
 
 	switch (cmd) {
@@ -189,13 +189,15 @@
 
 			convert_from_efi_time(&eft, &wtime);
 
- 			return copy_to_user((void *)arg, &wtime, sizeof (struct rtc_time)) ? - EFAULT : 0;
+ 			return copy_to_user((void __user *)arg, &wtime,
+					    sizeof (struct rtc_time)) ? - EFAULT : 0;
 
 		case RTC_SET_TIME:
 
 			if (!capable(CAP_SYS_TIME)) return -EACCES;
 
-			if (copy_from_user(&wtime, (struct rtc_time *)arg, sizeof(struct rtc_time)) )
+			if (copy_from_user(&wtime, (struct rtc_time __user *)arg,
+					   sizeof(struct rtc_time)) )
 				return -EFAULT;
 
 			convert_to_efi_time(&wtime, &eft);
@@ -212,19 +214,19 @@
 
 			if (!capable(CAP_SYS_TIME)) return -EACCES;
 
-			ewp = (struct rtc_wkalrm *)arg;
+			ewp = (struct rtc_wkalrm __user *)arg;
 
 			if (  get_user(enabled, &ewp->enabled)
 			   || copy_from_user(&wtime, &ewp->time, sizeof(struct rtc_time)) )
 				return -EFAULT;
 
 			convert_to_efi_time(&wtime, &eft);
-			
+
 			spin_lock_irqsave(&efi_rtc_lock, flags);
 			/*
 			 * XXX Fixme:
 			 * As of EFI 0.92 with the firmware I have on my
-			 * machine this call does not seem to work quite 
+			 * machine this call does not seem to work quite
 			 * right
 			 */
 			status = efi.set_wakeup_time((efi_bool_t)enabled, &eft);
@@ -243,14 +245,15 @@
 
 			if (status != EFI_SUCCESS) return -EINVAL;
 
-			ewp = (struct rtc_wkalrm *)arg;
+			ewp = (struct rtc_wkalrm __user *)arg;
 
 			if (  put_user(enabled, &ewp->enabled)
 			   || put_user(pending, &ewp->pending)) return -EFAULT;
 
 			convert_from_efi_time(&eft, &wtime);
 
-			return copy_to_user((void *)&ewp->time, &wtime, sizeof(struct rtc_time)) ? -EFAULT : 0;
+			return copy_to_user(&ewp->time, &wtime,
+					    sizeof(struct rtc_time)) ? -EFAULT : 0;
 	}
 	return -EINVAL;
 }
=== include/asm-ia64/spinlock.h 1.21 vs edited ==--- 1.21/include/asm-ia64/spinlock.h	2004-05-10 04:25:44 -07:00
+++ edited/include/asm-ia64/spinlock.h	2004-10-01 09:06:44 -07:00
@@ -114,8 +114,8 @@
 #define spin_unlock_wait(x)	do { barrier(); } while ((x)->lock)
 
 typedef struct {
-	volatile int read_counter	: 31;
-	volatile int write_lock		:  1;
+	volatile unsigned int read_counter	: 31;
+	volatile unsigned int write_lock	:  1;
 } rwlock_t;
 #define RW_LOCK_UNLOCKED (rwlock_t) { 0, 0 }
 
