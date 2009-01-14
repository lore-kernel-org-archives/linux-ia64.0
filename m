From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 14 Jan 2009 21:25:54 +0000
Subject: Re: [PATCH] add rtc platform driver for EFI
Message-Id: <20090114132554.1efce88f.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090109005644.GH32403@ldl.fc.hp.com>
	<20090109032729.6e4cd5fd@i1501.lan.towertech.it>
	<20090109213615.GD31548@ldl.fc.hp.com>
	<20090113003934.0a7da676.akpm@linux-foundation.org>
	<20090114000043.GB24423@colo.lackof.org>
	<20090114011719.GD24423@colo.lackof.org>
	<20090114023055.1d22d09e@i1501.lan.towertech.it>
	<20090114041358.GA21357@ldl.fc.hp.com>
	<20090114043337.GB21357@ldl.fc.hp.com>
	<20090114115728.15f2db18@i1501.lan.towertech.it>
	<20090114173745.GA24492@ldl.fc.hp.com>
In-Reply-To: <20090114173745.GA24492@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dann frazier <dannf@dannf.org>
Cc: alessandro.zummo@towertech.it, rtc-linux@googlegroups.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, eranian@googlemail.com

On Wed, 14 Jan 2009 10:37:45 -0700
dann frazier <dannf@dannf.org> wrote:

> +#define LEAP_YEAR(year) ((!(year % 4) && (year % 100)) || !(year % 400))

gargh.  We should put a tax on #defines to discourage their consumption.


How about we do this:

From: Andrew Morton <akpm@linux-foundation.org>

- the LEAP_YEAR macro is buggy - it references its arg multiple times. 
  Fix this by turning it into a C function.

- give it a more approriate name

- Move it to rtc.h so that other .c files can use it, instead of copying it.

Cc: dann frazier <dannf@hp.com>
Cc: Alessandro Zummo <alessandro.zummo@towertech.it>
Cc: stephane eranian <eranian@googlemail.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: David Brownell <david-b@pacbell.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/rtc/rtc-lib.c |    7 +++----
 include/linux/rtc.h   |    6 ++++++
 2 files changed, 9 insertions(+), 4 deletions(-)

diff -puN drivers/rtc/rtc-lib.c~rtc-convert-leap_year-into-an-inline drivers/rtc/rtc-lib.c
--- a/drivers/rtc/rtc-lib.c~rtc-convert-leap_year-into-an-inline
+++ a/drivers/rtc/rtc-lib.c
@@ -26,14 +26,13 @@ static const unsigned short rtc_ydays[2]
 };
 
 #define LEAPS_THRU_END_OF(y) ((y)/4 - (y)/100 + (y)/400)
-#define LEAP_YEAR(year) ((!(year % 4) && (year % 100)) || !(year % 400))
 
 /*
  * The number of days in the month.
  */
 int rtc_month_days(unsigned int month, unsigned int year)
 {
-	return rtc_days_in_month[month] + (LEAP_YEAR(year) && month = 1);
+	return rtc_days_in_month[month] + (is_leap_year(year) && month = 1);
 }
 EXPORT_SYMBOL(rtc_month_days);
 
@@ -42,7 +41,7 @@ EXPORT_SYMBOL(rtc_month_days);
  */
 int rtc_year_days(unsigned int day, unsigned int month, unsigned int year)
 {
-	return rtc_ydays[LEAP_YEAR(year)][month] + day-1;
+	return rtc_ydays[is_leap_year(year)][month] + day-1;
 }
 EXPORT_SYMBOL(rtc_year_days);
 
@@ -66,7 +65,7 @@ void rtc_time_to_tm(unsigned long time, 
 		- LEAPS_THRU_END_OF(1970 - 1);
 	if (days < 0) {
 		year -= 1;
-		days += 365 + LEAP_YEAR(year);
+		days += 365 + is_leap_year(year);
 	}
 	tm->tm_year = year - 1900;
 	tm->tm_yday = days + 1;
diff -puN include/linux/rtc.h~rtc-convert-leap_year-into-an-inline include/linux/rtc.h
--- a/include/linux/rtc.h~rtc-convert-leap_year-into-an-inline
+++ a/include/linux/rtc.h
@@ -99,6 +99,7 @@ struct rtc_pll_info {
 
 #ifdef __KERNEL__
 
+#include <linux/types.h>
 #include <linux/interrupt.h>
 
 extern int rtc_month_days(unsigned int month, unsigned int year);
@@ -232,6 +233,11 @@ int rtc_register(rtc_task_t *task);
 int rtc_unregister(rtc_task_t *task);
 int rtc_control(rtc_task_t *t, unsigned int cmd, unsigned long arg);
 
+static inline bool is_leap_year(unsigned int year)
+{
+	return (!(year % 4) && (year % 100)) || !(year % 400);
+}
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_RTC_H_ */
_



and then we modify your patch thusly:


From: Andrew Morton <akpm@linux-foundation.org>

Use is_leap_year()

Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: Alessandro Zummo <alessandro.zummo@towertech.it>
Cc: David Brownell <david-b@pacbell.net>
Cc: dann frazier <dannf@dannf.org>
Cc: dann frazier <dannf@hp.com>
Cc: stephane eranian <eranian@googlemail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/rtc/rtc-efi.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff -puN arch/ia64/kernel/time.c~rtc-add-platform-driver-for-efi-fix arch/ia64/kernel/time.c
diff -puN drivers/rtc/Kconfig~rtc-add-platform-driver-for-efi-fix drivers/rtc/Kconfig
diff -puN drivers/rtc/Makefile~rtc-add-platform-driver-for-efi-fix drivers/rtc/Makefile
diff -puN drivers/rtc/rtc-efi.c~rtc-add-platform-driver-for-efi-fix drivers/rtc/rtc-efi.c
--- a/drivers/rtc/rtc-efi.c~rtc-add-platform-driver-for-efi-fix
+++ a/drivers/rtc/rtc-efi.c
@@ -26,8 +26,6 @@
  */
 #define EFI_RTC_EPOCH		1998
 
-#define LEAP_YEAR(year) ((!(year % 4) && (year % 100)) || !(year % 400))
-
 /*
  * returns day of the year [0-365]
  */
@@ -54,7 +52,7 @@ compute_wday(efi_time_t *eft)
 	}
 
 	for (y = EFI_RTC_EPOCH; y < eft->year; y++)
-		ndays += 365 + (LEAP_YEAR(y) ? 1 : 0);
+		ndays += 365 + (is_leap_year(y) ? 1 : 0);
 
 	ndays += compute_yday(eft);
 
_

