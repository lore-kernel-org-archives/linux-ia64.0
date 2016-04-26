From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 26 Apr 2016 21:44:05 +0000
Subject: [PATCH 1/8] char/rtc: replace blacklist with whitelist
Message-Id: <1461707052-1337718-2-git-send-email-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461707052-1337718-1-git-send-email-arnd@arndb.de>
In-Reply-To: <1461707052-1337718-1-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, tony.luck@intel.com, geert@linux-m68k.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, mpe@ellerman.id.au, dalias@libc.org, dhowells@redhat.com, yasutake.koichi@jp.panasonic.com, rth@twiddle.net, ink@jurassic.park.msu.ru, linux-alpha@vger.kernel.org, x86@kernel.org, a.zummo@towertech.it, alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, rtc-linux@googlegroups.com, linux-arch@vger.kernel.org

Every new architecture has to add itself to the growing list of those
that do not support the legacy PC RTC driver.

This replaces the long list of architectures that don't support it
with a shorter list of those that do.

The list is taken from those architectures that have a non-empty
asm/mc146818rtc.h header file and were not explicitly blacklisted.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/char/Kconfig | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/char/Kconfig b/drivers/char/Kconfig
index 3ec0766ed5e9..66b5d48f409a 100644
--- a/drivers/char/Kconfig
+++ b/drivers/char/Kconfig
@@ -279,8 +279,7 @@ if RTC_LIB=n
 
 config RTC
 	tristate "Enhanced Real Time Clock Support (legacy PC RTC driver)"
-	depends on !PPC && !PARISC && !IA64 && !M68K && !SPARC && !FRV \
-			&& !ARM && !SUPERH && !S390 && !AVR32 && !BLACKFIN && !UML
+	depends on ALPHA || (MIPS && MACH_LOONGSON64) || MN10300 || X86
 	---help---
 	  If you say Y here and create a character special file /dev/rtc with
 	  major number 10 and minor number 135 using mknod ("man mknod"), you
-- 
2.7.0

