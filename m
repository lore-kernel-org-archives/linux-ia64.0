From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 18 May 2005 17:57:21 +0000
Subject: [PATCH] ia64: Selectable Timer Interrupt Frequency
Message-Id: <Pine.LNX.4.62.0505181053180.21019@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patch applies on top of the i386/x86_64 frequency patch discussed
at http://marc.theaimsgroup.com/?t1627646200004&r=1&w=2
and in the mm tree now.

It allows a selectable timer interrupt frequency of 100, 250 and 1000 HZ.
Reducing the timer frequency may have important performance benefits on 
large systems.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.12-rc4/arch/ia64/Kconfig
=================================--- linux-2.6.12-rc4.orig/arch/ia64/Kconfig	2005-05-12 18:39:27.000000000 -0700
+++ linux-2.6.12-rc4/arch/ia64/Kconfig	2005-05-18 10:27:27.000000000 -0700
@@ -157,6 +157,8 @@ config IA64_PAGE_SIZE_64KB
 
 endchoice
 
+source kernel/Kconfig.hz
+
 config IA64_BRL_EMU
 	bool
 	depends on ITANIUM
Index: linux-2.6.12-rc4/include/asm-ia64/param.h
=================================--- linux-2.6.12-rc4.orig/include/asm-ia64/param.h	2005-03-01 23:38:09.000000000 -0800
+++ linux-2.6.12-rc4/include/asm-ia64/param.h	2005-05-18 10:26:45.000000000 -0700
@@ -27,7 +27,7 @@
    */
 #  define HZ	  32
 # else
-#  define HZ	1024
+#  define HZ	CONFIG_HZ
 # endif
 # define USER_HZ	HZ
 # define CLOCKS_PER_SEC	HZ	/* frequency at which times() counts */
