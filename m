From: "H. J. Lu" <hjl@lucon.org>
Date: Thu, 07 Oct 2004 19:48:49 +0000
Subject: Allow -mtune=merced for gcc 3.4
Message-Id: <20041007194849.GA32425@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Gcc 3.4.2 fixed ia64 -mtune=merced regressions on Linux 2.6 kernel:

http://gcc.gnu.org/bugzilla/show_bug.cgi?id278

I have been using this patch for several months now.


H.J.
--
--- linux-2.6.8/arch/ia64/Makefile.merced	2004-08-30 10:38:31.733105785 -0700
+++ linux-2.6.8/arch/ia64/Makefile	2004-08-30 11:03:38.206994164 -0700
@@ -40,8 +40,7 @@ $(error Sorry, your compiler is too old.
 endif
 
 ifeq ($(GCC_VERSION),0304)
-# Workaround Itanium 1 bugs in gcc 3.4.
-#	cflags-$(CONFIG_ITANIUM)	+= -mtune=merced
+	cflags-$(CONFIG_ITANIUM)	+= -mtune=merced
 	cflags-$(CONFIG_MCKINLEY)	+= -mtune=mckinley
 endif
 
