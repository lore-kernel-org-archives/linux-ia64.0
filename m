From: Gary Hade <garyhade@us.ibm.com>
Date: Thu, 06 Jun 2002 23:59:05 +0000
Subject: [Linux-ia64] [Patch] Add ia64 dispersal analysis capability to objdump
Message-Id: <marc-linux-ia64-105590701905651@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
Enclosed is a patch that adds ia64 dispersal analysis capability
to objdump.

The dispersal analysis is implemented as an optional feature of 
the disassembler which is initiated/controlled via ia64 specific 
disassembler options.  The analysis results are inserted in the 
disassembly output.

This patch supports Itanium 1 only.  Code providing support for 
Itanium 2 already exists.  A patch incorporating the Itanium 2
support can be provided after Intel makes the information public.

I hope that those of you that are working on ia64 code optimization
find this feature useful.

If there are any questions/problems please note that I will be
on vacation and not checking email starting 13-June and not
returning until 8-July.

Regards,
Gary

Credit:
The original dispersal analysis code was developed by Steve 
Christiansen for Itanium 2 as a stand-alone utility which 
processed `objdump -d` output read from stdin.  I added the 
Itanium 1 support and incorporated the code into the disassembler.

-- 
Gary Hade
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc



diff -urpNX binutils-exclude src-orig/binutils/doc/binutils.texi src-i1/binutils/doc/binutils.texi
--- src-orig/binutils/doc/binutils.texi	Thu Mar  7 21:42:15 2002
+++ src-i1/binutils/doc/binutils.texi	Wed Jun  5 14:28:44 2002
@@ -1586,6 +1586,15 @@ For PPC, @option{booke}, @option{booke32
 disassembly of BookE instructions.  @option{32} and @option{64} select
 PowerPC and PowerPC64 disassembly, respectively.
 
+For ia64, @option{dispersal-i1} causes Itanium 1 dispersal analysis
+to be included in the disassembly output.
+By default, the dispersal analysis is restarted at each section or 
+function.  When @option{dispersal-allsyms} is specified, the analysis 
+is restarted at every symbol.  The dispersal analysis output for 
+each instruction includes the clock cycle and stall reasons with 
+@samp{S} for stop, @samp{B} for branch, @samp{R[...]} for execution 
+resources, and @samp{L[...]} for latencies.
+
 @item -p
 @itemx --private-headers
 Print information that is specific to the object file format.  The exact
diff -urpNX binutils-exclude src-orig/include/dis-asm.h src-i1/include/dis-asm.h
--- src-orig/include/dis-asm.h	Tue May 28 07:08:14 2002
+++ src-i1/include/dis-asm.h	Wed Jun  5 13:35:08 2002
@@ -246,6 +246,8 @@ extern int  get_arm_regname_num_options 
 extern int  set_arm_regname_option         PARAMS ((int));
 extern int  get_arm_regnames               PARAMS ((int, const char **, const char **, const char ***));
 
+extern void print_ia64_disassembler_options PARAMS ((FILE *));
+
 /* Fetch the disassembler for a given BFD, if that support is available.  */
 extern disassembler_ftype disassembler	PARAMS ((bfd *));
 
diff -urpNX binutils-exclude src-orig/opcodes/Makefile.am src-i1/opcodes/Makefile.am
--- src-orig/opcodes/Makefile.am	Thu May 30 21:27:35 2002
+++ src-i1/opcodes/Makefile.am	Wed Jun  5 13:52:05 2002
@@ -29,6 +29,7 @@ HFILES = \
 	h8500-opc.h \
 	ia64-asmtab.h \
 	ia64-opc.h \
+	ia64-dsprsl.h \
 	m32r-desc.h m32r-opc.h \
 	mcore-opc.h \
 	openrisc-desc.h openrisc-opc.h \
@@ -84,6 +85,7 @@ CFILES = \
 	ia64-opc.c \
 	ia64-gen.c \
 	ia64-asmtab.c \
+	ia64-dsprsl.c \
 	m32r-asm.c \
 	m32r-desc.c \
 	m32r-dis.c \
@@ -178,6 +180,7 @@ ALL_MACHINES = \
 	i960-dis.lo \
 	ia64-dis.lo \
 	ia64-opc.lo \
+	ia64-dsprsl.lo \
 	m32r-asm.lo \
 	m32r-desc.lo \
 	m32r-dis.lo \
@@ -516,7 +519,8 @@ i860-dis.lo: i860-dis.c $(INCDIR)/dis-as
 i960-dis.lo: i960-dis.c sysdep.h config.h $(INCDIR)/ansidecl.h \
   $(INCDIR)/dis-asm.h $(BFD_H) $(INCDIR)/symcat.h
 ia64-dis.lo: ia64-dis.c $(INCDIR)/dis-asm.h $(BFD_H) \
-  $(INCDIR)/ansidecl.h $(INCDIR)/symcat.h $(INCDIR)/opcode/ia64.h
+  $(INCDIR)/ansidecl.h $(INCDIR)/symcat.h $(INCDIR)/opcode/ia64.h \
+  ia64-dsprsl.h
 ia64-opc-a.lo: ia64-opc-a.c ia64-opc.h $(INCDIR)/opcode/ia64.h \
   $(BFD_H) $(INCDIR)/ansidecl.h $(INCDIR)/symcat.h
 ia64-opc-b.lo: ia64-opc-b.c ia64-opc.h $(INCDIR)/opcode/ia64.h \
@@ -537,6 +541,9 @@ ia64-gen.lo: ia64-gen.c $(INCDIR)/anside
   ia64-opc-a.c ia64-opc-i.c ia64-opc-m.c ia64-opc-b.c \
   ia64-opc-f.c ia64-opc-x.c ia64-opc-d.c
 ia64-asmtab.lo: ia64-asmtab.c
+ia64-dsprsl.lo: ia64-dsprsl.c $(INCDIR)/dis-asm.h $(BFD_H) \
+  $(INCDIR)/ansidecl.h $(INCDIR)/symcat.h $(INCDIR)/opcode/ia64.h \
+  ia64-dsprsl.h
 m32r-asm.lo: m32r-asm.c sysdep.h config.h $(INCDIR)/ansidecl.h \
   $(BFD_H) $(INCDIR)/symcat.h m32r-desc.h $(INCDIR)/opcode/cgen.h \
   m32r-opc.h opintl.h $(INCDIR)/xregex.h $(INCDIR)/xregex2.h \
diff -urpNX binutils-exclude src-orig/opcodes/Makefile.in src-i1/opcodes/Makefile.in
--- src-orig/opcodes/Makefile.in	Thu May 30 21:27:36 2002
+++ src-i1/opcodes/Makefile.in	Wed Jun  5 16:12:03 2002
@@ -139,6 +139,7 @@ HFILES = \
 	h8500-opc.h \
 	ia64-asmtab.h \
 	ia64-opc.h \
+	ia64-dsprsl.h \
 	m32r-desc.h m32r-opc.h \
 	mcore-opc.h \
 	openrisc-desc.h openrisc-opc.h \
@@ -195,6 +196,7 @@ CFILES = \
 	ia64-opc.c \
 	ia64-gen.c \
 	ia64-asmtab.c \
+	ia64-dsprsl.c \
 	m32r-asm.c \
 	m32r-desc.c \
 	m32r-dis.c \
@@ -290,6 +292,7 @@ ALL_MACHINES = \
 	i960-dis.lo \
 	ia64-dis.lo \
 	ia64-opc.lo \
+	ia64-dsprsl.lo \
 	m32r-asm.lo \
 	m32r-desc.lo \
 	m32r-dis.lo \
@@ -421,7 +424,7 @@ acinclude.m4 aclocal.m4 config.in config
 
 DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS) $(TEXINFOS) $(EXTRA_DIST)
 
-TAR = tar
+TAR = gtar
 GZIP_ENV = --best
 SOURCES = libopcodes.a.c $(libopcodes_la_SOURCES)
 OBJECTS = libopcodes.a.$(OBJEXT) $(libopcodes_la_OBJECTS)
@@ -1012,7 +1015,8 @@ i860-dis.lo: i860-dis.c $(INCDIR)/dis-as
 i960-dis.lo: i960-dis.c sysdep.h config.h $(INCDIR)/ansidecl.h \
   $(INCDIR)/dis-asm.h $(BFD_H) $(INCDIR)/symcat.h
 ia64-dis.lo: ia64-dis.c $(INCDIR)/dis-asm.h $(BFD_H) \
-  $(INCDIR)/ansidecl.h $(INCDIR)/symcat.h $(INCDIR)/opcode/ia64.h
+  $(INCDIR)/ansidecl.h $(INCDIR)/symcat.h $(INCDIR)/opcode/ia64.h \
+  ia64-dsprsl.h
 ia64-opc-a.lo: ia64-opc-a.c ia64-opc.h $(INCDIR)/opcode/ia64.h \
   $(BFD_H) $(INCDIR)/ansidecl.h $(INCDIR)/symcat.h
 ia64-opc-b.lo: ia64-opc-b.c ia64-opc.h $(INCDIR)/opcode/ia64.h \
@@ -1033,6 +1037,9 @@ ia64-gen.lo: ia64-gen.c $(INCDIR)/anside
   ia64-opc-a.c ia64-opc-i.c ia64-opc-m.c ia64-opc-b.c \
   ia64-opc-f.c ia64-opc-x.c ia64-opc-d.c
 ia64-asmtab.lo: ia64-asmtab.c
+ia64-dsprsl.lo: ia64-dsprsl.c $(INCDIR)/dis-asm.h $(BFD_H) \
+  $(INCDIR)/ansidecl.h $(INCDIR)/symcat.h $(INCDIR)/opcode/ia64.h \
+  ia64-dsprsl.h
 m32r-asm.lo: m32r-asm.c sysdep.h config.h $(INCDIR)/ansidecl.h \
   $(BFD_H) $(INCDIR)/symcat.h m32r-desc.h $(INCDIR)/opcode/cgen.h \
   m32r-opc.h opintl.h $(INCDIR)/xregex.h $(INCDIR)/xregex2.h \
diff -urpNX binutils-exclude src-orig/opcodes/configure src-i1/opcodes/configure
--- src-orig/opcodes/configure	Mon Jun  3 19:57:44 2002
+++ src-i1/opcodes/configure	Wed Jun  5 16:12:03 2002
@@ -3255,7 +3255,7 @@ EOF
 
 fi
 
-for ac_hdr in unistd.h
+for ac_hdr in stdlib.h unistd.h sys/stat.h sys/types.h
 do
 ac_safe=`echo "$ac_hdr" | sed 'y%./+-%__p_%'`
 echo $ac_n "checking for $ac_hdr""... $ac_c" 1>&6
@@ -3387,11 +3387,24 @@ else
 #include <fcntl.h>
 #include <sys/mman.h>
 
+#if HAVE_SYS_TYPES_H
+# include <sys/types.h>
+#endif
+
+#if HAVE_STDLIB_H
+# include <stdlib.h>
+#endif
+
+#if HAVE_SYS_STAT_H
+# include <sys/stat.h>
+#endif
+
+#if HAVE_UNISTD_H
+# include <unistd.h>
+#endif
+
 /* This mess was copied from the GNU getpagesize.h.  */
 #ifndef HAVE_GETPAGESIZE
-# ifdef HAVE_UNISTD_H
-#  include <unistd.h>
-# endif
 
 /* Assume that all systems that can run configure have sys/param.h.  */
 # ifndef HAVE_SYS_PARAM_H
@@ -3499,7 +3512,7 @@ main()
 }
 
 EOF
-if { (eval echo configure:3503: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext} && (./conftest; exit) 2>/dev/null
+if { (eval echo configure:3516: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext} && (./conftest; exit) 2>/dev/null
 then
   ac_cv_func_mmap_fixed_mapped=yes
 else
@@ -3527,17 +3540,17 @@ unistd.h values.h sys/param.h
 do
 ac_safe=`echo "$ac_hdr" | sed 'y%./+-%__p_%'`
 echo $ac_n "checking for $ac_hdr""... $ac_c" 1>&6
-echo "configure:3531: checking for $ac_hdr" >&5
+echo "configure:3544: checking for $ac_hdr" >&5
 if eval "test \"`echo '$''{'ac_cv_header_$ac_safe'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
   cat > conftest.$ac_ext <<EOF
-#line 3536 "configure"
+#line 3549 "configure"
 #include "confdefs.h"
 #include <$ac_hdr>
 EOF
 ac_try="$ac_cpp conftest.$ac_ext >/dev/null 2>conftest.out"
-{ (eval echo configure:3541: \"$ac_try\") 1>&5; (eval $ac_try) 2>&5; }
+{ (eval echo configure:3554: \"$ac_try\") 1>&5; (eval $ac_try) 2>&5; }
 ac_err=`grep -v '^ *+' conftest.out | grep -v "^conftest.${ac_ext}\$"`
 if test -z "$ac_err"; then
   rm -rf conftest*
@@ -3567,12 +3580,12 @@ done
 __argz_count __argz_stringify __argz_next
 do
 echo $ac_n "checking for $ac_func""... $ac_c" 1>&6
-echo "configure:3571: checking for $ac_func" >&5
+echo "configure:3584: checking for $ac_func" >&5
 if eval "test \"`echo '$''{'ac_cv_func_$ac_func'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
   cat > conftest.$ac_ext <<EOF
-#line 3576 "configure"
+#line 3589 "configure"
 #include "confdefs.h"
 /* System header to define __stub macros and hopefully few prototypes,
     which can conflict with char $ac_func(); below.  */
@@ -3595,7 +3608,7 @@ $ac_func();
 
 ; return 0; }
 EOF
-if { (eval echo configure:3599: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
+if { (eval echo configure:3612: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
   rm -rf conftest*
   eval "ac_cv_func_$ac_func=yes"
 else
@@ -3624,12 +3637,12 @@ done
      for ac_func in stpcpy
 do
 echo $ac_n "checking for $ac_func""... $ac_c" 1>&6
-echo "configure:3628: checking for $ac_func" >&5
+echo "configure:3641: checking for $ac_func" >&5
 if eval "test \"`echo '$''{'ac_cv_func_$ac_func'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
   cat > conftest.$ac_ext <<EOF
-#line 3633 "configure"
+#line 3646 "configure"
 #include "confdefs.h"
 /* System header to define __stub macros and hopefully few prototypes,
     which can conflict with char $ac_func(); below.  */
@@ -3652,7 +3665,7 @@ $ac_func();
 
 ; return 0; }
 EOF
-if { (eval echo configure:3656: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
+if { (eval echo configure:3669: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
   rm -rf conftest*
   eval "ac_cv_func_$ac_func=yes"
 else
@@ -3686,19 +3699,19 @@ EOF
 
    if test $ac_cv_header_locale_h = yes; then
     echo $ac_n "checking for LC_MESSAGES""... $ac_c" 1>&6
-echo "configure:3690: checking for LC_MESSAGES" >&5
+echo "configure:3703: checking for LC_MESSAGES" >&5
 if eval "test \"`echo '$''{'am_cv_val_LC_MESSAGES'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
   cat > conftest.$ac_ext <<EOF
-#line 3695 "configure"
+#line 3708 "configure"
 #include "confdefs.h"
 #include <locale.h>
 int main() {
 return LC_MESSAGES
 ; return 0; }
 EOF
-if { (eval echo configure:3702: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
+if { (eval echo configure:3715: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
   rm -rf conftest*
   am_cv_val_LC_MESSAGES=yes
 else
@@ -3719,7 +3732,7 @@ EOF
     fi
   fi
    echo $ac_n "checking whether NLS is requested""... $ac_c" 1>&6
-echo "configure:3723: checking whether NLS is requested" >&5
+echo "configure:3736: checking whether NLS is requested" >&5
         # Check whether --enable-nls or --disable-nls was given.
 if test "${enable_nls+set}" = set; then
   enableval="$enable_nls"
@@ -3739,7 +3752,7 @@ fi
 EOF
 
       echo $ac_n "checking whether included gettext is requested""... $ac_c" 1>&6
-echo "configure:3743: checking whether included gettext is requested" >&5
+echo "configure:3756: checking whether included gettext is requested" >&5
       # Check whether --with-included-gettext or --without-included-gettext was given.
 if test "${with_included_gettext+set}" = set; then
   withval="$with_included_gettext"
@@ -3758,17 +3771,17 @@ fi
 
 	ac_safe=`echo "libintl.h" | sed 'y%./+-%__p_%'`
 echo $ac_n "checking for libintl.h""... $ac_c" 1>&6
-echo "configure:3762: checking for libintl.h" >&5
+echo "configure:3775: checking for libintl.h" >&5
 if eval "test \"`echo '$''{'ac_cv_header_$ac_safe'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
   cat > conftest.$ac_ext <<EOF
-#line 3767 "configure"
+#line 3780 "configure"
 #include "confdefs.h"
 #include <libintl.h>
 EOF
 ac_try="$ac_cpp conftest.$ac_ext >/dev/null 2>conftest.out"
-{ (eval echo configure:3772: \"$ac_try\") 1>&5; (eval $ac_try) 2>&5; }
+{ (eval echo configure:3785: \"$ac_try\") 1>&5; (eval $ac_try) 2>&5; }
 ac_err=`grep -v '^ *+' conftest.out | grep -v "^conftest.${ac_ext}\$"`
 if test -z "$ac_err"; then
   rm -rf conftest*
@@ -3785,19 +3798,19 @@ fi
 if eval "test \"`echo '$ac_cv_header_'$ac_safe`\" = yes"; then
   echo "$ac_t""yes" 1>&6
   echo $ac_n "checking for gettext in libc""... $ac_c" 1>&6
-echo "configure:3789: checking for gettext in libc" >&5
+echo "configure:3802: checking for gettext in libc" >&5
 if eval "test \"`echo '$''{'gt_cv_func_gettext_libc'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
   cat > conftest.$ac_ext <<EOF
-#line 3794 "configure"
+#line 3807 "configure"
 #include "confdefs.h"
 #include <libintl.h>
 int main() {
 return (int) gettext ("")
 ; return 0; }
 EOF
-if { (eval echo configure:3801: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
+if { (eval echo configure:3814: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
   rm -rf conftest*
   gt_cv_func_gettext_libc=yes
 else
@@ -3813,7 +3826,7 @@ echo "$ac_t""$gt_cv_func_gettext_libc" 1
 
 	   if test "$gt_cv_func_gettext_libc" != "yes"; then
 	     echo $ac_n "checking for bindtextdomain in -lintl""... $ac_c" 1>&6
-echo "configure:3817: checking for bindtextdomain in -lintl" >&5
+echo "configure:3830: checking for bindtextdomain in -lintl" >&5
 ac_lib_var=`echo intl'_'bindtextdomain | sed 'y%./+-%__p_%'`
 if eval "test \"`echo '$''{'ac_cv_lib_$ac_lib_var'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
@@ -3821,7 +3834,7 @@ else
   ac_save_LIBS="$LIBS"
 LIBS="-lintl  $LIBS"
 cat > conftest.$ac_ext <<EOF
-#line 3825 "configure"
+#line 3838 "configure"
 #include "confdefs.h"
 /* Override any gcc2 internal prototype to avoid an error.  */
 /* We use char because int might match the return type of a gcc2
@@ -3832,7 +3845,7 @@ int main() {
 bindtextdomain()
 ; return 0; }
 EOF
-if { (eval echo configure:3836: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
+if { (eval echo configure:3849: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
   rm -rf conftest*
   eval "ac_cv_lib_$ac_lib_var=yes"
 else
@@ -3848,19 +3861,19 @@ fi
 if eval "test \"`echo '$ac_cv_lib_'$ac_lib_var`\" = yes"; then
   echo "$ac_t""yes" 1>&6
   echo $ac_n "checking for gettext in libintl""... $ac_c" 1>&6
-echo "configure:3852: checking for gettext in libintl" >&5
+echo "configure:3865: checking for gettext in libintl" >&5
 if eval "test \"`echo '$''{'gt_cv_func_gettext_libintl'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
   cat > conftest.$ac_ext <<EOF
-#line 3857 "configure"
+#line 3870 "configure"
 #include "confdefs.h"
 
 int main() {
 return (int) gettext ("")
 ; return 0; }
 EOF
-if { (eval echo configure:3864: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
+if { (eval echo configure:3877: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
   rm -rf conftest*
   gt_cv_func_gettext_libintl=yes
 else
@@ -3888,7 +3901,7 @@ EOF
 	      # Extract the first word of "msgfmt", so it can be a program name with args.
 set dummy msgfmt; ac_word=$2
 echo $ac_n "checking for $ac_word""... $ac_c" 1>&6
-echo "configure:3892: checking for $ac_word" >&5
+echo "configure:3905: checking for $ac_word" >&5
 if eval "test \"`echo '$''{'ac_cv_path_MSGFMT'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
@@ -3922,12 +3935,12 @@ fi
 		for ac_func in dcgettext
 do
 echo $ac_n "checking for $ac_func""... $ac_c" 1>&6
-echo "configure:3926: checking for $ac_func" >&5
+echo "configure:3939: checking for $ac_func" >&5
 if eval "test \"`echo '$''{'ac_cv_func_$ac_func'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
   cat > conftest.$ac_ext <<EOF
-#line 3931 "configure"
+#line 3944 "configure"
 #include "confdefs.h"
 /* System header to define __stub macros and hopefully few prototypes,
     which can conflict with char $ac_func(); below.  */
@@ -3950,7 +3963,7 @@ $ac_func();
 
 ; return 0; }
 EOF
-if { (eval echo configure:3954: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
+if { (eval echo configure:3967: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
   rm -rf conftest*
   eval "ac_cv_func_$ac_func=yes"
 else
@@ -3977,7 +3990,7 @@ done
 		# Extract the first word of "gmsgfmt", so it can be a program name with args.
 set dummy gmsgfmt; ac_word=$2
 echo $ac_n "checking for $ac_word""... $ac_c" 1>&6
-echo "configure:3981: checking for $ac_word" >&5
+echo "configure:3994: checking for $ac_word" >&5
 if eval "test \"`echo '$''{'ac_cv_path_GMSGFMT'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
@@ -4013,7 +4026,7 @@ fi
 		# Extract the first word of "xgettext", so it can be a program name with args.
 set dummy xgettext; ac_word=$2
 echo $ac_n "checking for $ac_word""... $ac_c" 1>&6
-echo "configure:4017: checking for $ac_word" >&5
+echo "configure:4030: checking for $ac_word" >&5
 if eval "test \"`echo '$''{'ac_cv_path_XGETTEXT'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
@@ -4045,7 +4058,7 @@ else
 fi
 
 		cat > conftest.$ac_ext <<EOF
-#line 4049 "configure"
+#line 4062 "configure"
 #include "confdefs.h"
 
 int main() {
@@ -4053,7 +4066,7 @@ extern int _nl_msg_cat_cntr;
 			       return _nl_msg_cat_cntr
 ; return 0; }
 EOF
-if { (eval echo configure:4057: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
+if { (eval echo configure:4070: \"$ac_link\") 1>&5; (eval $ac_link) 2>&5; } && test -s conftest${ac_exeext}; then
   rm -rf conftest*
   CATOBJEXT=.gmo
 		   DATADIRNAME=share
@@ -4085,7 +4098,7 @@ fi
         # Extract the first word of "msgfmt", so it can be a program name with args.
 set dummy msgfmt; ac_word=$2
 echo $ac_n "checking for $ac_word""... $ac_c" 1>&6
-echo "configure:4089: checking for $ac_word" >&5
+echo "configure:4102: checking for $ac_word" >&5
 if eval "test \"`echo '$''{'ac_cv_path_MSGFMT'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
@@ -4119,7 +4132,7 @@ fi
         # Extract the first word of "gmsgfmt", so it can be a program name with args.
 set dummy gmsgfmt; ac_word=$2
 echo $ac_n "checking for $ac_word""... $ac_c" 1>&6
-echo "configure:4123: checking for $ac_word" >&5
+echo "configure:4136: checking for $ac_word" >&5
 if eval "test \"`echo '$''{'ac_cv_path_GMSGFMT'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
@@ -4155,7 +4168,7 @@ fi
         # Extract the first word of "xgettext", so it can be a program name with args.
 set dummy xgettext; ac_word=$2
 echo $ac_n "checking for $ac_word""... $ac_c" 1>&6
-echo "configure:4159: checking for $ac_word" >&5
+echo "configure:4172: checking for $ac_word" >&5
 if eval "test \"`echo '$''{'ac_cv_path_XGETTEXT'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
@@ -4245,7 +4258,7 @@ fi
        LINGUAS      else
        echo $ac_n "checking for catalogs to be installed""... $ac_c" 1>&6
-echo "configure:4249: checking for catalogs to be installed" >&5
+echo "configure:4262: checking for catalogs to be installed" >&5
        NEW_LINGUAS        for lang in ${LINGUAS=$ALL_LINGUAS}; do
          case "$ALL_LINGUAS" in
@@ -4273,17 +4286,17 @@ echo "configure:4249: checking for catal
       if test "$CATOBJEXT" = ".cat"; then
 	 ac_safe=`echo "linux/version.h" | sed 'y%./+-%__p_%'`
 echo $ac_n "checking for linux/version.h""... $ac_c" 1>&6
-echo "configure:4277: checking for linux/version.h" >&5
+echo "configure:4290: checking for linux/version.h" >&5
 if eval "test \"`echo '$''{'ac_cv_header_$ac_safe'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
   cat > conftest.$ac_ext <<EOF
-#line 4282 "configure"
+#line 4295 "configure"
 #include "confdefs.h"
 #include <linux/version.h>
 EOF
 ac_try="$ac_cpp conftest.$ac_ext >/dev/null 2>conftest.out"
-{ (eval echo configure:4287: \"$ac_try\") 1>&5; (eval $ac_try) 2>&5; }
+{ (eval echo configure:4300: \"$ac_try\") 1>&5; (eval $ac_try) 2>&5; }
 ac_err=`grep -v '^ *+' conftest.out | grep -v "^conftest.${ac_ext}\$"`
 if test -z "$ac_err"; then
   rm -rf conftest*
@@ -4361,7 +4374,7 @@ if test "x$cross_compiling" = "xno"; the
   EXEEXT_FOR_BUILD='$(EXEEXT)'
 else
   echo $ac_n "checking for build system executable suffix""... $ac_c" 1>&6
-echo "configure:4365: checking for build system executable suffix" >&5
+echo "configure:4378: checking for build system executable suffix" >&5
 if eval "test \"`echo '$''{'bfd_cv_build_exeext'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
@@ -4398,7 +4411,7 @@ fi
 # SVR4 /usr/ucb/install, which tries to use the nonexistent group "staff"
 # ./install, which can be erroneously created by make from ./install.sh.
 echo $ac_n "checking for a BSD compatible install""... $ac_c" 1>&6
-echo "configure:4402: checking for a BSD compatible install" >&5
+echo "configure:4415: checking for a BSD compatible install" >&5
 if test -z "$INSTALL"; then
 if eval "test \"`echo '$''{'ac_cv_path_install'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
@@ -4455,17 +4468,17 @@ for ac_hdr in string.h strings.h stdlib.
 do
 ac_safe=`echo "$ac_hdr" | sed 'y%./+-%__p_%'`
 echo $ac_n "checking for $ac_hdr""... $ac_c" 1>&6
-echo "configure:4459: checking for $ac_hdr" >&5
+echo "configure:4472: checking for $ac_hdr" >&5
 if eval "test \"`echo '$''{'ac_cv_header_$ac_safe'+set}'`\" = set"; then
   echo $ac_n "(cached) $ac_c" 1>&6
 else
   cat > conftest.$ac_ext <<EOF
-#line 4464 "configure"
+#line 4477 "configure"
 #include "confdefs.h"
 #include <$ac_hdr>
 EOF
 ac_try="$ac_cpp conftest.$ac_ext >/dev/null 2>conftest.out"
-{ (eval echo configure:4469: \"$ac_try\") 1>&5; (eval $ac_try) 2>&5; }
+{ (eval echo configure:4482: \"$ac_try\") 1>&5; (eval $ac_try) 2>&5; }
 ac_err=`grep -v '^ *+' conftest.out | grep -v "^conftest.${ac_ext}\$"`
 if test -z "$ac_err"; then
   rm -rf conftest*
@@ -4600,7 +4613,7 @@ if test x${all_targets} = xfalse ; then
 	bfd_i386_arch)		ta="$ta i386-dis.lo" ;;
 	bfd_i860_arch)		ta="$ta i860-dis.lo" ;;
 	bfd_i960_arch)		ta="$ta i960-dis.lo" ;;
-	bfd_ia64_arch)		ta="$ta ia64-dis.lo ia64-opc.lo" ;;
+	bfd_ia64_arch)		ta="$ta ia64-dis.lo ia64-opc.lo ia64-dsprsl.lo" ;;
 	bfd_m32r_arch)		ta="$ta m32r-asm.lo m32r-desc.lo m32r-dis.lo m32r-ibld.lo m32r-opc.lo m32r-opinst.lo" using_cgen=yes ;;
 	bfd_m68hc11_arch)	ta="$ta m68hc11-dis.lo m68hc11-opc.lo" ;;
 	bfd_m68hc12_arch)	ta="$ta m68hc11-dis.lo m68hc11-opc.lo" ;;
diff -urpNX binutils-exclude src-orig/opcodes/configure.in src-i1/opcodes/configure.in
--- src-orig/opcodes/configure.in	Mon Jun  3 19:57:44 2002
+++ src-i1/opcodes/configure.in	Wed Jun  5 13:59:30 2002
@@ -188,7 +188,7 @@ if test x${all_targets} = xfalse ; then
 	bfd_i386_arch)		ta="$ta i386-dis.lo" ;;
 	bfd_i860_arch)		ta="$ta i860-dis.lo" ;;
 	bfd_i960_arch)		ta="$ta i960-dis.lo" ;;
-	bfd_ia64_arch)		ta="$ta ia64-dis.lo ia64-opc.lo" ;;
+	bfd_ia64_arch)		ta="$ta ia64-dis.lo ia64-opc.lo ia64-dsprsl.lo" ;;
 	bfd_m32r_arch)		ta="$ta m32r-asm.lo m32r-desc.lo m32r-dis.lo m32r-ibld.lo m32r-opc.lo m32r-opinst.lo" using_cgen=yes ;;
 	bfd_m68hc11_arch)	ta="$ta m68hc11-dis.lo m68hc11-opc.lo" ;;
 	bfd_m68hc12_arch)	ta="$ta m68hc11-dis.lo m68hc11-opc.lo" ;;
diff -urpNX binutils-exclude src-orig/opcodes/disassemble.c src-i1/opcodes/disassemble.c
--- src-orig/opcodes/disassemble.c	Tue May 28 07:08:47 2002
+++ src-i1/opcodes/disassemble.c	Wed Jun  5 13:31:20 2002
@@ -349,6 +349,9 @@ disassembler_usage (stream)
 #ifdef ARCH_arm
   print_arm_disassembler_options (stream);
 #endif
+#ifdef ARCH_ia64
+  print_ia64_disassembler_options (stream);
+#endif
 
   return;
 }
diff -urpNX binutils-exclude src-orig/opcodes/ia64-dis.c src-i1/opcodes/ia64-dis.c
--- src-orig/opcodes/ia64-dis.c	Tue Mar 13 14:58:35 2001
+++ src-i1/opcodes/ia64-dis.c	Wed Jun  5 14:25:39 2002
@@ -24,9 +24,15 @@
 
 #include "dis-asm.h"
 #include "opcode/ia64.h"
+#include "opintl.h"
+#include "ia64-dsprsl.h"
 
 #define NELEMS(a)	((int) (sizeof (a) / sizeof (a[0])))
 
+typedef struct ia64_disasm_pvt_info {
+  ia64_dsprsl_info dsprsl_info;
+} ia64_disasm_pvt_info;
+
 /* Disassemble ia64 instruction.  */
 
 /* Return the instruction type for OPCODE found in unit UNIT. */
@@ -65,6 +71,40 @@ unit_to_type (ia64_insn opcode, enum ia6
   return type;
 }
 
+/* parse disassembler options, return non-zero if an option requiring 
+   private data was encountered */
+static int
+parse_disasm_opts(struct disassemble_info *info)
+{
+  int dsprsl_opts;
+
+  dsprsl_opts = dsprsl_parse_opts_ia64 (info->disassembler_options);
+
+  /* avoid multiple parsing of options */
+  info->disassembler_options = NULL;
+
+  if (dsprsl_opts)
+    return 1;
+
+  return 0;
+}
+
+/* Allocate and initialize disassembler private data */
+static int
+init_disasm_pvt_info (struct disassemble_info *info)
+{
+  ia64_disasm_pvt_info *disasm_info; 
+
+  if ((disasm_info = calloc (sizeof (ia64_disasm_pvt_info), 1)) = NULL)
+    return -1;
+
+  dsprsl_init_info_ia64(&disasm_info->dsprsl_info);
+
+  info->private_data = disasm_info;
+
+  return 1;
+}
+
 int
 print_insn_ia64 (bfd_vma memaddr, struct disassemble_info *info)
 {
@@ -78,6 +118,13 @@ print_insn_ia64 (bfd_vma memaddr, struct
   enum ia64_unit unit;
   char regname[16];
 
+  if (info->disassembler_options)
+    if (parse_disasm_opts (info))
+      {
+	if (init_disasm_pvt_info (info) = -1)
+	  return -1;
+      }
+
   if (info->bytes_per_line = 0)
     info->bytes_per_line = 6;
   info->display_endian = info->endian;
@@ -105,12 +152,6 @@ print_insn_ia64 (bfd_vma memaddr, struct
   slot[1] = ((t0 >> 46) & 0x3ffff) | ((t1 & 0x7fffff) << 18);
   slot[2] = (t1 >> 23) & 0x1ffffffffffLL;
 
-  tname = ia64_templ_desc[template].name;
-  if (slotnum = 0)
-    (*info->fprintf_func) (info->stream, "[%s] ", tname);
-  else
-    (*info->fprintf_func) (info->stream, "      ", tname);
-
   unit = ia64_templ_desc[template].exec_unit[slotnum];
 
   if (template = 2 && slotnum = 1)
@@ -129,6 +170,22 @@ print_insn_ia64 (bfd_vma memaddr, struct
   if (idesc = NULL)
     goto decoding_failed;
 
+  if (info->private_data
+      && ((ia64_disasm_pvt_info *)info->private_data)->dsprsl_info.options)
+    {
+      /* private data contains dispersal analysis option(s), 
+	 call the analyzer */
+      char *msg_str = dsprsl_analyze_ia64 (info, memaddr, idesc, slotnum,
+					   s_bit, template);
+      (*info->fprintf_func) (info->stream, "%s ", msg_str);
+    }
+
+  tname = ia64_templ_desc[template].name;
+  if (slotnum = 0)
+    (*info->fprintf_func) (info->stream, "[%s] ", tname);
+  else
+    (*info->fprintf_func) (info->stream, "      ", tname);
+
   /* print predicate, if any: */
 
   if ((idesc->flags & IA64_OPCODE_NO_PRED)
@@ -271,3 +328,22 @@ print_insn_ia64 (bfd_vma memaddr, struct
   (*info->fprintf_func) (info->stream, "      data8 %#011llx", insn);
   goto failed;
 }
+
+void
+print_ia64_disassembler_options (FILE *stream)
+{
+  fprintf (stream, _("\n\
+The following ia64 specific disassembler options are supported for use with\n\
+the -M switch:\n"));
+
+  fprintf (stream, "%-33s%s\n", "  dispersal-i1",
+           "Include Itanium 1 dispersal analysis in the");
+  fprintf (stream, "%-33s%s\n", "", "  disassembly output");
+
+  fprintf (stream, "%-33s%s\n", "  dispersal-allsyms",
+           "Restart dispersal analysis at every symbol");
+  fprintf (stream, "%-33s%s\n", "", "  default: restart at each function or section");
+
+  fprintf (stream, "\n");
+}
+
diff -urpNX binutils-exclude src-orig/opcodes/ia64-dsprsl.c src-i1/opcodes/ia64-dsprsl.c
--- src-orig/opcodes/ia64-dsprsl.c	Wed Dec 31 16:00:00 1969
+++ src-i1/opcodes/ia64-dsprsl.c	Wed Jun  5 14:23:58 2002
@@ -0,0 +1,545 @@
+/* ia64-disprsl.c -- IA-64 dispersal analysis
+   Copyright 2002 Free Software Foundation, Inc.
+   Contributed by Gary Hade <garyhade@us.ibm.com>
+
+   This file is part of GNU binutils.
+
+   This program is free software; you can redistribute it and/or modify
+   it under the terms of the GNU General Public License as published by
+   the Free Software Foundation; either version 2 of the License, or
+   (at your option) any later version.
+
+   This program is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+   GNU General Public License for more details.
+
+   You should have received a copy of the GNU General Public License
+   along with this file; see the file COPYING.  If not, write to the
+   Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
+   02111-1307, USA.  */
+
+#include <string.h>
+#include "dis-asm.h"
+#include "opcode/ia64.h"
+#include "ia64-dsprsl.h"
+
+#define NELEMS(a)	((int) (sizeof (a) / sizeof (a[0])))
+
+/* Code assumes three instructions per bundle and that BNDLS_PER_WINDOW 
+   is a power of two. */
+#define BNDLS_PER_WINDOW 2
+
+/* Issue ports, some may not be used depending on Itanium model.
+   If ports are added or removed revise NUM_PORTS in ia64-dsprsl.h */
+#define NO_PORT_AVAILABLE 0
+#define M0 1
+#define M1 2
+#define M2 3
+#define M3 4
+#define I0 5
+#define I1 6
+#define B0 7
+#define B1 8
+#define B2 9
+#define F0 10
+#define F1 11
+#define PORT_NAMES_INIT \
+  {"noport", "M0", "M1", "M2", "M3", "I0", "I1", "B0", "B1", "B2", "F0", "F1"}
+
+/* Bundle types */
+#define MII  0
+#define MI_I 1
+#define MLX  2
+	/*  3 unused */
+#define MMI  4
+#define M_MI 5
+#define MFI  6
+#define MMF  7
+#define MIB  8
+#define MBB  9
+	/* 10 unused */
+#define BBB 11
+#define MMB 12
+	/* 13 unused */
+#define MFB 14
+	/* 15 unused */
+
+static int dsprsl_opts = 0;
+ia64_dsprsl_info *dsprsl_info = NULL;
+
+/* Itanium model independent */
+static int available_port (int);
+static int find_first_free_port (int, int);
+static int find_reg (const char *, int);
+static int inputs_ready (const struct ia64_opcode *);
+static void print_reg_name (int);
+static void reset_dsprsl_info (void);
+static void set_regs (const struct ia64_opcode *, int, int, int);
+static void tick (void);
+
+/* Itanium 1 */
+static int issue_i1 (const struct ia64_opcode *);
+static int find_port_i1 (const struct ia64_opcode *); 
+static void record_latency_i1 (const struct ia64_opcode *);
+
+/* Check to see if a port is free. */
+static int
+available_port (port)
+     int port;
+{
+  dsprsl_info->reason[dsprsl_info->nreason++] = port;
+  return dsprsl_info->busy[port]? 0 : port;
+}
+
+/* Find the first free port in [port1..port2]. */
+static int
+find_first_free_port (port1, port2)
+     int port1, port2;
+{
+  int port;
+
+  for (port = port1; port <= port2; port++)
+    if (available_port (port))
+      return port;
+  return NO_PORT_AVAILABLE;
+}
+
+/* Itanium 1
+   Find a free issue port for an instruction based on the dispersal 
+   rules in the November 2001 "Intel(R) Itanium(TM) Processor 
+   Reference Manual for Software Optimization", section 3.4.2. */
+static int
+find_port_i1 (idesc)
+    const struct ia64_opcode *idesc; 
+{
+  int port = 0; 
+  int bndl_no = dsprsl_info->bndl_no;
+  int bndl_type = dsprsl_info->bndl_type;
+  int insn_no = dsprsl_info->insn_no;
+
+  switch (ia64_templ_desc[bndl_type].exec_unit[insn_no])
+    {
+      case IA64_UNIT_I:
+	if (bndl_no = 1 && insn_no = 2)
+	  port = available_port (I1);
+	else
+	  port = find_first_free_port (I0, I1);
+	break;
+      case IA64_UNIT_M:
+	port = find_first_free_port (M0, M1);
+	break;
+      case IA64_UNIT_B:
+	if (bndl_type = MBB || bndl_type = BBB)
+	  port = available_port (B0 + insn_no);
+	if (bndl_type = MIB || bndl_type = MFB || bndl_type = MMB)
+	  {
+	    if (strncmp (idesc->name, "brp", 3) = 0
+		|| strncmp (idesc->name, "nop.b", 5) = 0)
+	      port = available_port (B0);
+	    else
+	      port = available_port (B2);
+	  }
+	break;
+      case IA64_UNIT_F:
+	port = available_port (F0 + bndl_no);
+	break;
+      case IA64_UNIT_L:
+      case IA64_UNIT_X:
+	port = find_first_free_port (I0 + bndl_no, I1)?
+		available_port (F0 + bndl_no) : 0;
+	break;
+      case IA64_UNIT_NIL:
+      case IA64_NUM_UNITS:
+	/* do nothing */
+	break;
+    }
+    return port;
+}
+
+/* Find the destination registers and save the cycle numbers in which
+   they will contain valid results.  Two latencies are passed in because
+   some FP instructions have different latencies for predicate vs FP
+   registers. */
+static void
+set_regs (idesc, latency, platency, producer_info)
+     const struct ia64_opcode *idesc; 
+     int latency, platency, producer_info;
+{
+  int i, reg;
+  const struct ia64_operand *odesc;
+  ia64_insn reg_num;
+
+  for (i = 0; i < idesc->num_outputs; ++i)
+    {
+      odesc = elf64_ia64_operands + idesc->operands[i];
+      if (odesc->class = IA64_OPND_CLASS_REG)
+	{
+	  (*odesc->extract) (odesc, idesc->opcode, &reg_num);
+	  if ((reg = find_reg (odesc->str, reg_num)) != -1)
+	    {
+	      dsprsl_info->latency_tab[reg].cycle +		(*odesc->str = 'p'? platency : latency) + dsprsl_info->cycle;
+	      dsprsl_info->latency_tab[reg].producer_info = producer_info;
+	    }
+	}
+    }
+}
+
+/* Itanium 1
+   Determine type of instruction and destination register(s), 
+   and record the cycle in which the register(s) will be available to 
+   consumers.  We don't need to do anything for most instructions because 
+   the value will be available in the next cycle, thus any previously-stored 
+   cycle number is good enough.
+   TODO: multi-media instructions are completely ignored for now,
+   as are moves to/from br, pr, cr, ar, and move indirect. */
+static void
+record_latency_i1 (idesc)
+     const struct ia64_opcode *idesc;
+{
+  int producer_info = 0;
+
+  if (idesc->type = IA64_TYPE_F)
+    {
+      if (strncmp (idesc->name, "fcmp", 4) = 0)
+	{
+	  /* If the producer is fcmp then the predicate latency is:
+	       1 if consumer is a branch instruction
+	       2 if consumer is a non-branch instruction
+	     We do not know what the consumer looks like yet so we use
+	     a latency of 2 and remember that the producer is fcmp.  If
+	     we later find that the consuming instruction is a branch we 
+	     adjust the latency to 1. */
+	  producer_info |= PRODUCER_IS_FCMP;
+	}
+      set_regs (idesc, 5, 2, producer_info);
+    }
+  else if (idesc->type = IA64_TYPE_M)
+    {
+      if (strncmp (idesc->name, "getf", 4) = 0)
+        set_regs (idesc, 9, 9, producer_info);
+      else if (strncmp (idesc->name, "setf", 4) = 0)
+        set_regs (idesc, 2, 2, producer_info);
+      else if (strncmp (idesc->name, "ldf", 3) = 0)
+        set_regs (idesc, 9, 9, producer_info);
+      else if (strncmp (idesc->name, "ld", 2) = 0)
+        set_regs (idesc, 2, 2, producer_info);
+    }
+}
+
+/* Given a register class and number, return the register's
+   index in the latency table */
+static int
+find_reg (reg_class, reg_num)
+     const char *reg_class;
+     int reg_num;
+{
+  char *reg_classp;
+  char *reg_classes = REG_CLASSES_INIT;
+
+  /* First character of reg_class indicates register class (r, f, ...). */
+  reg_classp = strchr (reg_classes, *reg_class);
+
+  /* Validate class and register number */
+  if (reg_classp = NULL || reg_num < 0 || reg_num >= REG_N_IN_CLASS)
+    return -1;
+
+  return ((reg_classp - reg_classes) << REG_CLASS_SHIFT) | reg_num;
+}
+
+/* Returns: 1 if all input registers are available.
+	    0 if we need to wait because of a latency. */
+static int
+inputs_ready (idesc)
+    const struct ia64_opcode *idesc; 
+{
+  int i, reg;
+  ia64_insn reg_num;
+  int regs_avail = 1;
+  const struct ia64_operand *odesc;
+
+  /* Check for predicate */
+  reg_num = idesc->opcode & 0x3f;
+  if (!((idesc->flags & IA64_OPCODE_NO_PRED) || reg_num = 0))
+    {
+      if ((reg = find_reg ("p", (int)reg_num)) != -1)
+	{
+	  int cycle = dsprsl_info->latency_tab[reg].cycle;
+
+	  if ((dsprsl_info->latency_tab[reg].producer_info & PRODUCER_IS_FCMP)
+	      && (strncmp (idesc->name, "br", 2) = 0))
+	    {
+	      /* If the producing instruction is fcmp and the consuming
+		 instruction is a branch then the predicate register is
+		 available one cycle earlier */
+	      cycle--;
+	    }
+	  if (cycle > dsprsl_info->cycle)
+	    {
+	      regs_avail = 0;
+	      dsprsl_info->reason[dsprsl_info->nreason++] = reg;
+	    }
+	}
+    }
+
+  /* Check for input regs */
+  for (i = 0; i < NELEMS (idesc->operands) && idesc->operands[i]; i++)
+    {
+      odesc = elf64_ia64_operands + idesc->operands[i];
+      switch (odesc->class)
+	{
+	  case IA64_OPND_CLASS_IND:
+	    /* Use of a register for a load/store address implies one cycle
+	       greater latency in most cases. */
+	    (*odesc->extract) (odesc, idesc->opcode, &reg_num);
+	    if ((reg = find_reg ("r", reg_num)) != -1)
+	      {
+		if ((dsprsl_info->latency_tab[reg].cycle + 1)
+		      > dsprsl_info->cycle)
+		  {
+		    regs_avail = 0;
+		    dsprsl_info->reason[dsprsl_info->nreason++] = reg;
+		  }
+	      }
+	    break;
+	  case IA64_OPND_CLASS_REG:
+	    if (i >= idesc->num_outputs)
+	      {
+		(*odesc->extract) (odesc, idesc->opcode, &reg_num);
+		if ((reg = find_reg (odesc->str, reg_num)) != -1)
+		  {
+		    if (dsprsl_info->latency_tab[reg].cycle
+			  > dsprsl_info->cycle)
+		      {
+			regs_avail = 0;
+			dsprsl_info->reason[dsprsl_info->nreason++] = reg;
+		      }
+		  }
+	      }
+	    break;
+	  default:
+	    /* do nothing */
+	    break;
+	}
+    }
+  return regs_avail;
+}
+
+/* Given the latency table register index, output the register name */
+static void
+print_reg_name (reg)
+     int reg;
+{
+  char *reg_classes = REG_CLASSES_INIT;
+
+  char reg_class = reg_classes[reg >> REG_CLASS_SHIFT];
+  int reg_num = (reg & REG_MASK);
+
+  dsprsl_info->rslt_bufp += 
+	sprintf(dsprsl_info->rslt_bufp, "%c%d", reg_class, reg_num);
+}
+
+/* Itanium 1
+   Issue instruction if possible.  A stall may be caused by no available 
+   port found using dispersal rules, or bundle is one of the 
+   processor-specific special cases, or input values have been delayed 
+   by instruction latency. */
+static int
+issue_i1 (idesc)
+     const struct ia64_opcode *idesc; 
+{
+  int port;  /* port that can accept this instruction */
+  int stall = 0;
+  char *dsprsl_port_names[] = PORT_NAMES_INIT;
+
+  /* Find an issue port */
+  dsprsl_info->nreason = 0;
+  port = find_port_i1 (idesc);
+
+  if (port = NO_PORT_AVAILABLE)
+    {
+      int i;
+
+      dsprsl_info->rslt_bufp += sprintf(dsprsl_info->rslt_bufp, " R[");
+      for (i = 0; i < dsprsl_info->nreason; i++)
+	{
+	  char *port_name = dsprsl_port_names[dsprsl_info->reason[i]];
+
+	  if (i > 0)
+	    dsprsl_info->rslt_bufp += sprintf(dsprsl_info->rslt_bufp, ",");
+	  dsprsl_info->rslt_bufp ++		sprintf(dsprsl_info->rslt_bufp, "%s", port_name);
+	}
+      dsprsl_info->rslt_bufp += sprintf(dsprsl_info->rslt_bufp, "]");
+      stall = 1;
+    }
+
+  /* Input registers ready? */
+  dsprsl_info->nreason = 0;
+  if (! inputs_ready (idesc))
+    {
+      int i;
+
+      dsprsl_info->rslt_bufp += sprintf (dsprsl_info->rslt_bufp, " L[");
+      for (i = 0; i < dsprsl_info->nreason; i++)
+	{
+	  if (i > 0)
+	    dsprsl_info->rslt_bufp += sprintf (dsprsl_info->rslt_bufp, ",");
+	  print_reg_name (dsprsl_info->reason[i]);
+	}
+      dsprsl_info->rslt_bufp += sprintf(dsprsl_info->rslt_bufp, "]");
+      stall = 1;
+    }
+
+  if (stall)
+    return 0;
+
+  /* Mark port as busy and record clock at which destination register
+     will be available */
+  dsprsl_info->busy[port] = 1;
+  record_latency_i1 (idesc); 
+
+  return 1;
+}
+
+/* Advance the clock, clear ports for next cycle, do a bundle shift */
+static void
+tick ()
+{
+  dsprsl_info->cycle++;
+  memset (dsprsl_info->busy, 0, sizeof (dsprsl_info->busy));
+  dsprsl_info->bndl_no = 0;
+}
+
+static void
+reset_dsprsl_info ()
+{
+  dsprsl_info->bndl_no = 0;
+  dsprsl_info->insn_no = 0;
+  dsprsl_info->cycle = 0;
+  dsprsl_info->stop_next = 0;
+  memset (dsprsl_info->latency_tab, 0, sizeof (dsprsl_info->latency_tab));
+}
+
+void
+dsprsl_init_info_ia64(dispersal_info)
+     ia64_dsprsl_info *dispersal_info;
+{
+  dsprsl_info = dispersal_info;
+
+  if (dsprsl_opts & DSPRSL_OPT_I1)
+    dsprsl_info->issue_fn = issue_i1;
+
+  dsprsl_info->options = dsprsl_opts;
+}
+
+/* Scan disassembler options for dispersal analysis options. */
+int
+dsprsl_parse_opts_ia64 (disasm_options)
+     char *disasm_options;
+{
+  if (disasm_options)
+    {
+      if (strstr (disasm_options, "dispersal-allsyms"))
+        dsprsl_opts |= DSPRSL_OPT_ALLSYMS;
+
+      if (strstr (disasm_options, "dispersal-i1"))
+        dsprsl_opts |= DSPRSL_OPT_I1;
+
+      if (!(dsprsl_opts & DSPRSL_OPT_I1))
+        /* bad option combination, skip the analysis */
+        dsprsl_opts = 0;
+    }
+  return dsprsl_opts;
+}
+
+char *
+dsprsl_analyze_ia64 (disasm_info, memaddr, idesc, slotnum, s_bit, template)
+     struct disassemble_info *disasm_info; 
+     bfd_vma memaddr;
+     const struct ia64_opcode *idesc; 
+     int slotnum;
+     ia64_insn s_bit, template;
+{
+  boolean addr_is_sect_start = false;
+  boolean addr_has_sym = false;
+  boolean addr_is_funct_start = false;
+  char rslt_save_buf[RSLT_BUF_SIZE];
+
+  /* Initialize analysis result buffer and buffer pointer */
+  memset (dsprsl_info->rslt_buf, 0, sizeof (dsprsl_info->rslt_buf));
+  dsprsl_info->rslt_bufp = dsprsl_info->rslt_buf;
+
+  if ((memaddr = disasm_info->buffer_vma) && (slotnum = 0))
+    addr_is_sect_start = true;
+
+  if ((slotnum = 0)
+       && disasm_info->symbols
+       && (disasm_info->num_symbols > 0)
+       && (bfd_asymbol_value(disasm_info->symbols[0]) = memaddr))
+    addr_has_sym = true;
+
+  if ((strncmp (idesc->name, "alloc", 5) = 0) && addr_has_sym)
+    addr_is_funct_start = true;
+
+  if (addr_is_sect_start || addr_has_sym)
+    {
+      if (dsprsl_info->options & DSPRSL_OPT_ALLSYMS)
+	 reset_dsprsl_info ();
+      else
+	if (addr_is_funct_start || addr_is_sect_start)
+	 reset_dsprsl_info ();
+    }
+
+  dsprsl_info->bndl_type = template;
+
+  if (dsprsl_info->insn_no != slotnum && dsprsl_info->bndl_type != MLX)
+    /* decoding of previous instruction failed, correct instruction number */
+    dsprsl_info->insn_no = slotnum;
+
+  /* Print explicit stop if found while processing last instruction */
+  if (dsprsl_info->stop_next)
+    dsprsl_info->rslt_bufp += sprintf(dsprsl_info->rslt_bufp, " S");
+
+  /* Wait until the instruction is issued */
+  while (! (*dsprsl_info->issue_fn)(idesc))
+    tick ();
+
+  /* Insert current instruction cycle number at the start of the buffer */
+  memcpy(rslt_save_buf, dsprsl_info->rslt_buf, sizeof(rslt_save_buf));
+  dsprsl_info->rslt_bufp = dsprsl_info->rslt_buf;
+  dsprsl_info->rslt_bufp ++      sprintf(dsprsl_info->rslt_bufp, "%4d", dsprsl_info->cycle);
+  dsprsl_info->rslt_bufp ++      sprintf(dsprsl_info->rslt_bufp, "%-16s", rslt_save_buf);
+
+  /* Advance instruction counter */
+  dsprsl_info->insn_no++;
+  if (dsprsl_info->insn_no >= 3
+      || (dsprsl_info->bndl_type = MLX && dsprsl_info->insn_no = 2))
+    {
+      dsprsl_info->insn_no = 0;
+      dsprsl_info->bndl_no = (dsprsl_info->bndl_no + 1) % BNDLS_PER_WINDOW;
+    }
+
+  /* We need to wait until the next clock to start a new window */
+  if (dsprsl_info->insn_no = 0 && dsprsl_info->bndl_no = 0)
+    {
+      tick ();
+      return dsprsl_info->rslt_buf;
+    }
+
+  /* Check for explicit stop after current instruction, store result 
+   * to be used during processing of next instruction */
+  dsprsl_info->stop_next = 0;
+  if ((dsprsl_info->bndl_type = MI_I && dsprsl_info->insn_no = 2)
+      || (dsprsl_info->bndl_type = M_MI && dsprsl_info->insn_no = 1)
+      || (s_bit && dsprsl_info->insn_no = 0))
+    {
+      dsprsl_info->stop_next = 1;
+      tick ();
+    }
+
+  return dsprsl_info->rslt_buf;
+}
diff -urpNX binutils-exclude src-orig/opcodes/ia64-dsprsl.h src-i1/opcodes/ia64-dsprsl.h
--- src-orig/opcodes/ia64-dsprsl.h	Wed Dec 31 16:00:00 1969
+++ src-i1/opcodes/ia64-dsprsl.h	Wed Jun  5 14:21:15 2002
@@ -0,0 +1,74 @@
+/* ia64-disprsl.h -- IA-64 dispersal analysis
+   Copyright 2002 Free Software Foundation, Inc.
+   Contributed by Gary Hade <garyhade@us.ibm.com>
+
+   This file is part of GNU binutils.
+
+   This program is free software; you can redistribute it and/or modify
+   it under the terms of the GNU General Public License as published by
+   the Free Software Foundation; either version 2 of the License, or
+   (at your option) any later version.
+
+   This program is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+   GNU General Public License for more details.
+
+   You should have received a copy of the GNU General Public License
+   along with this file; see the file COPYING.  If not, write to the
+   Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
+   02111-1307, USA.  */
+
+#define RSLT_BUF_SIZE 256   /* dispersal analysis result text buffer size */
+#define NUM_PORTS      12   /* number of issue ports */
+
+/* For keeping track of latencies in the latency_tab array */
+#define REG_N_CLASSES     3  /* number of register classes (p,f,r) */
+#define REG_N_IN_CLASS  128  /* max number of registers in each class */
+#define REG_MASK       0x7f
+#define REG_CLASS_SHIFT   7
+#define REG_CLASSES_INIT "rfp"
+
+/* per-register latency record */
+struct latency {
+  int cycle;
+
+  /* producer info needed for evaluation of some consumers */
+  int producer_info;
+#define PRODUCER_IS_FCMP (1 << 0)
+};
+
+typedef struct ia64_dsprsl_info {
+  int bndl_no;		/* bundle number within dispersal window [0,1] */
+  int insn_no;		/* instruction number within bundle [0,1,2] */
+  int bndl_type;	/* bundle type */
+  int cycle;		/* cycle counter within current function */
+  int busy[NUM_PORTS];	/* Issue ports, some may not be used depending
+			   on the model within the processor family. */
+  int stop_next;	/* explicit stop specified after current instruction */
+  struct latency latency_tab[REG_N_CLASSES * REG_N_IN_CLASS];
+
+  /* dispersal analysis options provided via disassembler options */
+  int options;
+#define DSPRSL_OPT_ALLSYMS  (1 << 0)
+#define DSPRSL_OPT_I1       (1 << 1)
+
+  /* for reporting stall reasons */
+  int reason[NUM_PORTS];
+  int nreason;
+
+  /* storage for dispersal analysis result text */
+  char rslt_buf[RSLT_BUF_SIZE];
+  char *rslt_bufp;
+
+  /* issue function, varies with Itanium model */
+  int (*issue_fn)(const struct ia64_opcode *);
+} ia64_dsprsl_info;
+
+
+char *dsprsl_analyze_ia64 (struct disassemble_info *, bfd_vma,
+			   const struct ia64_opcode *, int, 
+			   ia64_insn, ia64_insn);
+int dsprsl_parse_opts_ia64 (char *);
+void dsprsl_init_info_ia64 (ia64_dsprsl_info *);
+

