From: Lars-Peter Clausen <lars@metafoo.de>
Date: Fri, 17 Jun 2011 11:40:31 +0000
Subject: [PATCH] firmware: Make firmware drivers generally available
Message-Id: <1308310831-27861-1-git-send-email-lars@metafoo.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110617103218.GA29723@opensource.wolfsonmicro.com>
In-Reply-To: <20110617103218.GA29723@opensource.wolfsonmicro.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Frysinger <vapier@gentoo.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, Mark Brown <broonie@opensource.wolfsonmicro.com>, Lars-Peter Clausen <lars@metafoo.de>

Currently only x86, ia64 and blackfin architectures include
drivers/firmware/Kconfig, as a result firmware drivers are only available on
these platforms. This has not been a problem historically, because all of the
firmware drivers were architecture specific.

But this has changed with the addition of the SigmaStudio firmware loader
(commit e359dc24 "sigma-firmware: loader for Analog Devices' SigmaStudio"),
which is used to parse and load firmware files for Analog Devices' SigmaDSP
processors. These DSPs are usually embedded in for example audio codecs, which
use the I2C or SPI bus for communication and are not architecture specific.
Thus make the firmware drivers generally available, so it can be used on all
architectures.

Note that this moves the Kconfig "Firmware Drivers" entry from the top-level to
the "Device Drivers" submenu for architectures which had it already available.

Reported-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
Signed-off-by: Lars-Peter Clausen <lars@metafoo.de>
---
 arch/blackfin/Kconfig |    2 --
 arch/ia64/Kconfig     |    2 --
 arch/x86/Kconfig      |    2 --
 drivers/Kconfig       |    2 ++
 4 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/arch/blackfin/Kconfig b/arch/blackfin/Kconfig
index d619b17..a7c1efa 100644
--- a/arch/blackfin/Kconfig
+++ b/arch/blackfin/Kconfig
@@ -1283,8 +1283,6 @@ source "net/Kconfig"
 
 source "drivers/Kconfig"
 
-source "drivers/firmware/Kconfig"
-
 source "fs/Kconfig"
 
 source "arch/blackfin/Kconfig.debug"
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 38280ef..34be81e 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -583,8 +583,6 @@ config CRASH_DUMP
 	  help
 	    Generate crash dump after being started by kexec.
 
-source "drivers/firmware/Kconfig"
-
 source "fs/Kconfig.binfmt"
 
 endmenu
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index da34972..e112693 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2153,8 +2153,6 @@ source "net/Kconfig"
 
 source "drivers/Kconfig"
 
-source "drivers/firmware/Kconfig"
-
 source "fs/Kconfig"
 
 source "arch/x86/Kconfig.debug"
diff --git a/drivers/Kconfig b/drivers/Kconfig
index 3bb154d..6b2c238 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -32,6 +32,8 @@ source "drivers/message/fusion/Kconfig"
 
 source "drivers/firewire/Kconfig"
 
+source "drivers/firmware/Kconfig"
+
 source "drivers/message/i2o/Kconfig"
 
 source "drivers/macintosh/Kconfig"
-- 
1.7.2.5

