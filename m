From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 26 Apr 2016 21:44:10 +0000
Subject: [PATCH 6/8] char/genrtc: parisc: use asm-generic/rtc.h
Message-Id: <1461707052-1337718-7-git-send-email-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461707052-1337718-1-git-send-email-arnd@arndb.de>
In-Reply-To: <1461707052-1337718-1-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, tony.luck@intel.com, geert@linux-m68k.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, mpe@ellerman.id.au, dalias@libc.org, dhowells@redhat.com, yasutake.koichi@jp.panasonic.com, rth@twiddle.net, ink@jurassic.park.msu.ru, linux-alpha@vger.kernel.org, x86@kernel.org, a.zummo@towertech.it, alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, rtc-linux@googlegroups.com, linux-arch@vger.kernel.org

The asm-generic/rtc.h header can now be included by
architectures that provide their own set_rtc_time/get_rtc_time
macros, letting us remove most of the common contents in
the powerpc implementation.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/parisc/include/asm/rtc.h | 38 +++++---------------------------------
 1 file changed, 5 insertions(+), 33 deletions(-)

diff --git a/arch/parisc/include/asm/rtc.h b/arch/parisc/include/asm/rtc.h
index 099d641a42c2..d06cc581ecc2 100644
--- a/arch/parisc/include/asm/rtc.h
+++ b/arch/parisc/include/asm/rtc.h
@@ -12,26 +12,15 @@
 
 #ifdef __KERNEL__
 
-#include <linux/rtc.h>
+#define get_rtc_time parisc_get_rtc_time
+#define set_rtc_time parisc_set_rtc_time
+#include <asm-generic/rtc.h>
 
 #include <asm/pdc.h>
 
 #define SECS_PER_HOUR   (60 * 60)
 #define SECS_PER_DAY    (SECS_PER_HOUR * 24)
 
-
-#define RTC_PIE 0x40		/* periodic interrupt enable */
-#define RTC_AIE 0x20		/* alarm interrupt enable */
-#define RTC_UIE 0x10		/* update-finished interrupt enable */
-
-#define RTC_BATT_BAD 0x100	/* battery bad */
-
-/* some dummy definitions */
-#define RTC_SQWE 0x08		/* enable square-wave output */
-#define RTC_DM_BINARY 0x04	/* all time/date values are BCD if clear */
-#define RTC_24H 0x02		/* 24 hour mode - else hours bit 7 means pm */
-#define RTC_DST_EN 0x01	        /* auto switch DST - works f. USA only */
-
 # define __isleap(year) \
   ((year) % 4 = 0 && ((year) % 100 != 0 || (year) % 400 = 0))
 
@@ -44,7 +33,7 @@ static const unsigned short int __mon_yday[2][13]  	{ 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366 }
 };
 
-static inline unsigned int get_rtc_time(struct rtc_time *wtime)
+static inline unsigned int parisc_get_rtc_time(struct rtc_time *wtime)
 {
 	struct pdc_tod tod_data;
 	long int days, rem, y;
@@ -96,7 +85,7 @@ static inline unsigned int get_rtc_time(struct rtc_time *wtime)
 	return RTC_24H;
 }
 
-static int set_rtc_time(struct rtc_time *wtime)
+static int parisc_set_rtc_time(struct rtc_time *wtime)
 {
 	u_int32_t secs;
 
@@ -110,22 +99,5 @@ static int set_rtc_time(struct rtc_time *wtime)
 
 }
 
-static inline unsigned int get_rtc_ss(void)
-{
-	struct rtc_time h;
-
-	get_rtc_time(&h);
-	return h.tm_sec;
-}
-
-static inline int get_rtc_pll(struct rtc_pll_info *pll)
-{
-	return -EINVAL;
-}
-static inline int set_rtc_pll(struct rtc_pll_info *pll)
-{
-	return -EINVAL;
-}
-
 #endif /* __KERNEL__ */
 #endif /* __ASM_RTC_H__ */
-- 
2.7.0

