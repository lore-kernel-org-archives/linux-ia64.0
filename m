From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 05 Aug 2003 01:46:15 +0000
Subject: Kill a warning if !CONFIG_SMP
Message-Id: <marc-linux-ia64-106004812230354@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,
	This kills a compilation warning if CONFIG_SMP is *not*
defined.


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1609  -> 1.1610 
#	include/asm-ia64/percpu.h	1.11    -> 1.12   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/05	peterc@gelato.unsw.edu.au	1.1610
# Kill warning: setup_per_cpu_areas defined differently in 
# different places if !CONFIG_SMP.
# --------------------------------------------
#
diff -Nru a/include/asm-ia64/percpu.h b/include/asm-ia64/percpu.h
--- a/include/asm-ia64/percpu.h	Tue Aug  5 11:45:34 2003
+++ b/include/asm-ia64/percpu.h	Tue Aug  5 11:45:34 2003
@@ -45,6 +45,7 @@
 #define __get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __ia64_per_cpu_var(local_per_cpu_offset)))
 
 extern void percpu_modcopy(void *pcpudst, const void *src, unsigned long size);
+extern void setup_per_cpu_areas (void);
 
 #else /* ! SMP */
 
@@ -55,10 +56,6 @@
 
 #define EXPORT_PER_CPU_SYMBOL(var)		EXPORT_SYMBOL(per_cpu__##var)
 #define EXPORT_PER_CPU_SYMBOL_GPL(var)		EXPORT_SYMBOL_GPL(per_cpu__##var)
-
-/* ia64-specific part: */
-
-extern void setup_per_cpu_areas (void);
 
 /*
  * Be extremely careful when taking the address of this variable!  Due to virtual
