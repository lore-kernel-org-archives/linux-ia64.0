From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 17 Feb 2006 13:22:45 +0000
Subject: [2.6 patch] show "SN Devices" menu only if CONFIG_SGI_SN
Message-Id: <20060217132245.GG4422@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jes@sgi.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On architectures like i386, the "Multimedia Capabilities Port drivers"
menu is visible, but it can't be visited since it contains nothing
usable for CONFIG_SGI_SN=n.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc3-mm1-full/drivers/sn/Kconfig.old	2006-02-17 14:07:11.000000000 +0100
+++ linux-2.6.16-rc3-mm1-full/drivers/sn/Kconfig	2006-02-17 14:07:37.000000000 +0100
@@ -3,6 +3,7 @@
 #
 
 menu "SN Devices"
+	depends on SGI_SN
 
 config SGI_IOC4
 	tristate "SGI IOC4 Base IO support"

