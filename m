From: "Bahnsen, Bruce" <bruce.bahnsen@intel.com>
Date: Tue, 21 Jan 2003 18:52:01 +0000
Subject: RE: [Linux-ia64] Error compiling 2.4.20 for i386
Message-Id: <marc-linux-ia64-105590709805736@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805709@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805709@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I applied the patch, and it booted just fine on i386. Maybe we are not too
far from common source after all?

Thanks,
Bruce

I seem to have mistakenly removed the declaration.  With the attached
patch on top of 2.4.20-ia64-021210, I was able to build an i386 image
(I didn't test it, though).  

I try not to gratuitously break other architectures, but when I
do, I'm happy to include fixes like this if people are interested
in doing them.

Bjorn

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.994   -> 1.995  
#	arch/i386/kernel/setup.c	1.59    -> 1.60   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/01/21	bjorn_helgaas@hp.com	1.995
# i386: Fix enable_acpi_smp_table merge botch.
# --------------------------------------------
#
diff -Nru a/arch/i386/kernel/setup.c b/arch/i386/kernel/setup.c
--- a/arch/i386/kernel/setup.c	Tue Jan 21 10:19:48 2003
+++ b/arch/i386/kernel/setup.c	Tue Jan 21 10:19:48 2003
@@ -175,6 +175,8 @@
 static u32 disabled_x86_caps[NCAPINTS] __initdata = { 0 };
 extern int blk_nohighio;
 
+int enable_acpi_smp_table;
+
 /*
  * This is set up by the setup-routine at boot-time
  */

