From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 26 Apr 2016 21:44:06 +0000
Subject: [PATCH 2/8] char/rtc: legacy RTC is no longer supported on x86
Message-Id: <1461707052-1337718-3-git-send-email-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461707052-1337718-1-git-send-email-arnd@arndb.de>
In-Reply-To: <1461707052-1337718-1-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, tony.luck@intel.com, geert@linux-m68k.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, mpe@ellerman.id.au, dalias@libc.org, dhowells@redhat.com, yasutake.koichi@jp.panasonic.com, rth@twiddle.net, ink@jurassic.park.msu.ru, linux-alpha@vger.kernel.org, x86@kernel.org, a.zummo@towertech.it, alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, rtc-linux@googlegroups.com, linux-arch@vger.kernel.org

Commit 3195ef59cb42 ("x86: Do full rtc synchronization with ntp") had
the side-effect of unconditionally enabling the RTC_LIB symbol on x86,
which in turn disables the selection of the CONFIG_RTC and
CONFIG_GEN_RTC drivers that contain a two older implementations of
the CONFIG_RTC_DRV_CMOS driver.

This removes x86 from the list.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/char/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/char/Kconfig b/drivers/char/Kconfig
index 66b5d48f409a..9bdb629fbaae 100644
--- a/drivers/char/Kconfig
+++ b/drivers/char/Kconfig
@@ -279,7 +279,7 @@ if RTC_LIB=n
 
 config RTC
 	tristate "Enhanced Real Time Clock Support (legacy PC RTC driver)"
-	depends on ALPHA || (MIPS && MACH_LOONGSON64) || MN10300 || X86
+	depends on ALPHA || (MIPS && MACH_LOONGSON64) || MN10300
 	---help---
 	  If you say Y here and create a character special file /dev/rtc with
 	  major number 10 and minor number 135 using mknod ("man mknod"), you
@@ -328,7 +328,7 @@ config JS_RTC
 config GEN_RTC
 	tristate "Generic /dev/rtc emulation"
 	depends on RTC!=y
-	depends on ALPHA || M68K || MN10300 || PARISC || PPC || X86
+	depends on ALPHA || M68K || MN10300 || PARISC || PPC
 	---help---
 	  If you say Y here and create a character special file /dev/rtc with
 	  major number 10 and minor number 135 using mknod ("man mknod"), you
-- 
2.7.0

