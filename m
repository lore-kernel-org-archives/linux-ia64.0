From: Jes Sorensen <jes@sgi.com>
Date: Fri, 17 Feb 2006 15:25:39 +0000
Subject: Re: [2.6 patch] show "SN Devices" menu only if CONFIG_SGI_SN
Message-Id: <yq08xsaxb0s.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060217132245.GG4422@stusta.de>
In-Reply-To: <20060217132245.GG4422@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> "Adrian" = Adrian Bunk <bunk@stusta.de> writes:

Adrian> On architectures like i386, the "Multimedia Capabilities Port
Adrian> drivers" menu is visible, but it can't be visited since it
Adrian> contains nothing usable for CONFIG_SGI_SN=n.

Thats only a third of the patch, if you want to do that, you should
remove the redundant SGI_SN checks below.

Like this.

Jes

 drivers/sn/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/sn/Kconfig
=================================--- linux-2.6.orig/drivers/sn/Kconfig
+++ linux-2.6/drivers/sn/Kconfig
@@ -3,10 +3,11 @@
 #
 
 menu "SN Devices"
+	depends on SGI_SN
 
 config SGI_IOC4
 	tristate "SGI IOC4 Base IO support"
-	depends on (IA64_GENERIC || IA64_SGI_SN2) && MMTIMER
+	depends on MMTIMER
 	default m
 	---help---
 	This option enables basic support for the SGI IOC4-based Base IO
@@ -19,7 +20,6 @@
 
 config SGI_IOC3
 	tristate "SGI IOC3 Base IO support"
-	depends on (IA64_GENERIC || IA64_SGI_SN2)
 	default m
 	---help---
 	This option enables basic support for the SGI IOC3-based Base IO
