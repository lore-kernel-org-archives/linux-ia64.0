From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Fri, 10 Jan 2003 01:38:36 +0000
Subject: [Linux-ia64] Patches for Cleaning offsets.h/print_offsets.h/print_offsets.s
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C2B848.FE634570"
Message-Id: <marc-linux-ia64-105590709805663@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C2B848.FE634570
Content-Type: text/plain

Hi,

2.5.52 and tpc.0.18 can't clean arch/ia64/tools/offsets.h, print_offsets.h,
print_offsets.s under arch/ia64/tools even with make
distclean/mrproper/clean. The feature is working for 2.4.20.

2.5.52 is supposed to clean the files by "make clean". Tpc.0.18 is supposed
to clean the files by "make mrproper". Thus, they have different fix
solutions.

Thanks.

-Fenghua


------_=_NextPart_000_01C2B848.FE634570
Content-Type: text/plain;
	name="kernel-2.4.18-tpc.0.18-clean_offset.diff"
Content-Disposition: attachment;
	filename="kernel-2.4.18-tpc.0.18-clean_offset.diff"

diff -Nur A/arch/ia64/tools/Makefile B/arch/ia64/tools/Makefile
--- A/arch/ia64/tools/Makefile	Thu Jan  9 20:16:16 2003
+++ B/arch/ia64/tools/Makefile	Thu Jan  9 20:16:58 2003
@@ -4,7 +4,7 @@
 
 all: 
 
-mrproper:
+mrproper: clean
 
 clean:
 	rm -f print_offsets.s print_offsets offsets.h

------_=_NextPart_000_01C2B848.FE634570
Content-Type: text/plain;
	name="linux-2.5.52-ia64-021221-clean_offset.diff"
Content-Disposition: attachment;
	filename="linux-2.5.52-ia64-021221-clean_offset.diff"

diff -Nur A/arch/ia64/Makefile B/arch/ia64/Makefile
--- A/arch/ia64/Makefile	Thu Jan  9 19:34:56 2003
+++ B/arch/ia64/Makefile	Thu Jan  9 19:35:36 2003
@@ -61,6 +61,7 @@
 archmrproper:
 archclean:
 	$(Q)$(MAKE) -f scripts/Makefile.clean obj=arch/ia64/boot
+	$(Q)$(MAKE) -f scripts/Makefile.clean obj=arch/ia64/tools
 
 CLEAN_FILES += include/asm-ia64/offsets.h vmlinux.gz bootloader
 
diff -Nur A/arch/ia64/tools/Makefile B/arch/ia64/tools/Makefile
--- A/arch/ia64/tools/Makefile	Thu Jan  9 19:34:56 2003
+++ B/arch/ia64/tools/Makefile	Thu Jan  9 19:35:36 2003
@@ -4,14 +4,7 @@
 
 src = $(obj)
 
-all:
-
-fastdep:
-
-mrproper: clean
-
-clean:
-	rm -f $(obj)/print_offsets.s $(obj)/print_offsets $(obj)/offsets.h
+clean-files := print_offsets.s print_offsets offsets.h
 
 $(TARGET): $(obj)/offsets.h
 	@if ! cmp -s $(obj)/offsets.h ${TARGET}; then	\

------_=_NextPart_000_01C2B848.FE634570--

