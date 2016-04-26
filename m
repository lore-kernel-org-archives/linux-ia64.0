From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 26 Apr 2016 21:44:11 +0000
Subject: [PATCH 7/8] char/genrtc: disallow building on Alpha
Message-Id: <1461707052-1337718-8-git-send-email-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461707052-1337718-1-git-send-email-arnd@arndb.de>
In-Reply-To: <1461707052-1337718-1-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, tony.luck@intel.com, geert@linux-m68k.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, mpe@ellerman.id.au, dalias@libc.org, dhowells@redhat.com, yasutake.koichi@jp.panasonic.com, rth@twiddle.net, ink@jurassic.park.msu.ru, linux-alpha@vger.kernel.org, x86@kernel.org, a.zummo@towertech.it, alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, rtc-linux@googlegroups.com, linux-arch@vger.kernel.org

The genrtc driver serves no purpose on Alpha because it drives the
same hardware as the original rtc.c driver, and the newer rtc-generic.c
or rtc-cmos.c drivers on architectures that use the asm-generic/rtc.h
header.

The defconfig uses CONFIG_RTC=y, so this driver is not used by default.
At one point it was used to abstract a quirk for the "Marvel" platform,
but it does not do this any more after the code was moved into yet
another driver in arch/alpha/kernel/rtc.c.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/char/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/char/Kconfig b/drivers/char/Kconfig
index 9bdb629fbaae..697510325b1d 100644
--- a/drivers/char/Kconfig
+++ b/drivers/char/Kconfig
@@ -328,7 +328,7 @@ config JS_RTC
 config GEN_RTC
 	tristate "Generic /dev/rtc emulation"
 	depends on RTC!=y
-	depends on ALPHA || M68K || MN10300 || PARISC || PPC
+	depends on M68K || MN10300 || PARISC || PPC
 	---help---
 	  If you say Y here and create a character special file /dev/rtc with
 	  major number 10 and minor number 135 using mknod ("man mknod"), you
-- 
2.7.0

