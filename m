From: Martin Hicks <mort@wildopensource.com>
Date: Tue, 20 May 2003 19:56:48 +0000
Subject: Re: [Linux-ia64] runtime platform detection in GENERIC kernels
Message-Id: <marc-linux-ia64-105590723705959@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Fri, May 16, 2003 at 01:35:52PM -0600, Alex Williamson wrote:
> Martin Hicks wrote:
> > Here is the next iteration, based on your suggestions.  It also caches
> > the result of the first acpi_get_sysname() call, since this really
> > shouldn't change while the machine is running.
> >
> 
> Martin,
> 
>    Everything is already in place to make this much easier.
> I was thinking something more like this:
> 
> #define ia64_platform_is(x) (strcmp(x,platform_name) = 0)
> 
> The name is stored in the machvec, so you don't need to cache
> it anywhere else.

Patch attached against Bjorn's 2.4 bk tree.

-- 
Wild Open Source Inc.                  mort@wildopensource.com

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1122  -> 1.1123 
#	include/asm-ia64/system.h	1.15    -> 1.16   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/20	mort@green.i.bork.org	1.1123
# Add a small macro ia64_platform_is(platform) which checks
# if the platform is indeed "platform".
# --------------------------------------------
#
diff -Nru a/include/asm-ia64/system.h b/include/asm-ia64/system.h
--- a/include/asm-ia64/system.h	Tue May 20 19:54:44 2003
+++ b/include/asm-ia64/system.h	Tue May 20 19:54:44 2003
@@ -27,6 +27,7 @@
 
 #include <linux/kernel.h>
 #include <linux/types.h>
+#include <linux/string.h>
 
 struct pci_vector_struct {
 	__u16 segment;	/* PCI Segment number */
@@ -290,6 +291,8 @@
 	__switch_to(prev,next,last);					\
 } while (0)
 #endif
+
+#define ia64_platform_is(x) (!strcmp(x, platform_name))
 
 #endif /* __KERNEL__ */
 


