From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 20 Jun 2003 17:47:44 +0000
Subject: Re: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105613167716254@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

diff -Nru a/arch/ia64/lib/Makefile b/arch/ia64/lib/Makefile
--- a/arch/ia64/lib/Makefile    Thu Jun 19 14:19:14 2003
+++ b/arch/ia64/lib/Makefile    Thu Jun 19 14:19:14 2003
@@ -13,6 +13,12 @@
 lib-$(CONFIG_MCKINLEY) += copy_page_mck.o memcpy_mck.o
 lib-$(CONFIG_PERFMON)  += carta_random.o

+ifeq ($(CONFIG_MD_RAID5),m)
+       lib-y += xor.o
+else
+       lib-$(CONFIG_MD_RAID5)  += xor.o
+endif
+

No need for this ifeq ....
lib-m should work as well as lib-y.
If this is not the case then let me know - I will fix kbuild then.

lib-m is actually documented!



diff -Nru a/usr/Makefile b/usr/Makefile
....
+$(obj)/initramfs_data.S: $(obj)/initramfs_data.cpio.gz
+       echo '.section ".init.ramfs", "a"' > $@
+       od -v -An -t x1 -w8 $^ | cut -c2- | sed -e s"/ /,0x/g" -e s"/^/.byte 0x"/ >> $@

Will .incbin really replace the above magic?
I have the following patch ready - but not submitted:
[Deleted trivial changes that just removed LDFLAGS_BLOB]

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1414  -> 1.1415 
#	   arch/ppc/Makefile	1.39    -> 1.40   
#	 arch/ppc64/Makefile	1.26    -> 1.27   
#	 arch/sparc/Makefile	1.23    -> 1.24   
#	 arch/h8300/Makefile	1.1     -> 1.2    
#	  arch/s390/Makefile	1.25    -> 1.26   
#	usr/initramfs_data.scr	1.1     ->         (deleted)      
#	  arch/i386/Makefile	1.52    -> 1.53   
#	        usr/Makefile	1.6     -> 1.7    
#	 arch/alpha/Makefile	1.24    -> 1.25   
#	    arch/sh/Makefile	1.16    -> 1.17   
#	arch/m68knommu/Makefile	1.7     -> 1.8    
#	arch/x86_64/Makefile	1.27    -> 1.28   
#	arch/parisc/Makefile	1.20    -> 1.21   
#	  arch/m68k/Makefile	1.11    -> 1.12   
#	arch/sparc64/Makefile	1.26    -> 1.27   
#	  arch/v850/Makefile	1.6     -> 1.7    
#	               (new)	        -> 1.1     usr/initramfs_data.S
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/18	sam@mars.ravnborg.org	1.1415
# usr: Create objectfile for usr filesystem using .incbin
# 
# Patch originally by HJ Lu.
# 
# The filesystem was previously embedded in a .o file using ld.
# Embedding the filesystem using ld broke as a result ia64 and maybe more
# architectures.
# 
# The better way to do this is to use the .incbin feature, as already
# used for vsyscall for i386. .incbin has the advantage that ELH header
# is correct, as required by ia64 - and maybe other archs.
# This change will break architectures relying on binutils older than
# 2.11.90.0.23 released on 2001-07-14.
# Most notably arm will break in some configurations due to this.
# The rationale behing introducing .incbin is that ia64 needs this change
# and the .incbin feature has been present in binutils for a number
# of years now.
# arm will thus have to catch up with binutils - or patch usr/Makefile
# to stay compatible with the 2.5 kernel.
# 
# The definition of LDFLAGS_BLOB removed for all architectures - it was 
# obsoleted by this change.
# Except for arm - that may require it due to the tool compatibility issue.
# --------------------------------------------
#
diff -Nru a/usr/Makefile b/usr/Makefile
--- a/usr/Makefile	Fri Jun 20 19:45:26 2003
+++ b/usr/Makefile	Fri Jun 20 19:45:26 2003
@@ -5,11 +5,10 @@
 
 clean-files := initramfs_data.cpio.gz
 
-LDFLAGS_initramfs_data.o := $(LDFLAGS_BLOB) -r -T
-
-$(obj)/initramfs_data.o: $(src)/initramfs_data.scr \
-			 $(obj)/initramfs_data.cpio.gz FORCE
-	$(call if_changed,ld)
+# initramfs_data.o contains the initramfs_data.cpio.gz image.
+# The image is included using .incbin, a dependency which is not
+# tracked automatically.
+$(obj)/initramfs_data.o: $(obj)/initramfs_data.cpio.gz FORCE
 
 # initramfs-y are the programs which will be copied into the CPIO
 # archive. Currently, the filenames are hardcoded in gen_init_cpio,
diff -Nru a/usr/initramfs_data.S b/usr/initramfs_data.S
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/usr/initramfs_data.S	Fri Jun 20 19:45:26 2003
@@ -0,0 +1,30 @@
+/*
+  initramfs_data includes the compressed binary that is the
+  filesystem used for early user space.
+  Note: Older versions of "as" (prior to binutils 2.11.90.0.23
+  released on 2001-07-14) dit not support .incbin.
+  If you are forced to use older binutils than that then the
+  following trick can be applied to create the resulting binary:
+
+
+  ld -m elf_i386  --format binary --oformat elf32-i386 -r \
+  -T initramfs_data.scr initramfs_data.cpio.gz -o initramfs_data.o
+   ld -m elf_i386  -r -o built-in.o initramfs_data.o
+
+  initramfs_data.scr looks like this:
+SECTIONS
+{
+       .init.ramfs : { *(.data) }
+}
+
+  The above example is for i386 - the parameters vary from architectures.
+  Eventually look up LDFLAGS_BLOB in an older version of the
+  arch/$(ARCH)/Makefile to see the flags used before .incbin was introduced.
+
+  Using .incbin has the advantage over ld that the correct flags are set
+  in the ELF header, as required by certain architectures.
+*/
+
+.section .init.ramfs,"a"
+.incbin "usr/initramfs_data.cpio.gz"
+
diff -Nru a/usr/initramfs_data.scr b/usr/initramfs_data.scr
--- a/usr/initramfs_data.scr	Fri Jun 20 19:45:26 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,4 +0,0 @@
-SECTIONS
-{
-	.init.ramfs : { *(.data) }
-}
