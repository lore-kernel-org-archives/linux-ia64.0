From: "H. J. Lu" <hjl@lucon.org>
Date: Mon, 28 Jun 2004 18:40:40 +0000
Subject: PATCH: Don't use -mtune=merced for gcc 3.4
Message-Id: <20040628184040.GA13181@lucon.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="SLDf9lqlvOQaIe6s"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Gcc 3.4 has a new DFA scheduler for ia64. Unfortunately, it is not
well tested for Itanium 1. When I tried to use gcc 3.4 to compile
2.6 kernel configured for Merced, gcc failed in many places:

http://gcc.gnu.org/bugzilla/show_bug.cgi?id=15598
http://gcc.gnu.org/bugzilla/show_bug.cgi?id=15653
http://gcc.gnu.org/bugzilla/show_bug.cgi?id=15655
http://gcc.gnu.org/bugzilla/show_bug.cgi?id=16130
http://gcc.gnu.org/bugzilla/show_bug.cgi?id=16142
http://gcc.gnu.org/bugzilla/show_bug.cgi?id=16143

Some of them have been fixed. But I am afraid many more remain. I don't
know how many Itanium 1 machines left in production use. If people want
to optimize kernel for Itanium 1, they can stick with the older gccs.
Or they should upgrade their machines. I think the gcc developer's time
should be better spent on somewhere else. I have been using this patch
for a while, kernel seems to work OK.


H.J.

--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.6-merced-1.patch"

--- linux-2.6.7/arch/ia64/Makefile.merced	2004-06-22 09:09:50.000000000 -0700
+++ linux-2.6.7/arch/ia64/Makefile	2004-06-22 09:12:03.000000000 -0700
@@ -43,7 +43,8 @@ endif
 
 ifeq ($(GCC_VERSION),3)
  ifeq ($(GCC_MINOR_VERSION),4)
-	cflags-$(CONFIG_ITANIUM)	+= -mtune=merced
+# Workaround Itanium 1 bugs in gcc 3.4.
+#	cflags-$(CONFIG_ITANIUM)	+= -mtune=merced
 	cflags-$(CONFIG_MCKINLEY)	+= -mtune=mckinley
  endif
 endif

--SLDf9lqlvOQaIe6s--
