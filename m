From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 09 Feb 2001 08:17:28 +0000
Subject: [Linux-ia64] binutils patch to restore IA-64 EFI support
Message-Id: <marc-linux-ia64-105590693005126@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[I tried to send this last night, but it bounced due to a mistyped
 domainname, so I'm resending it now...]

Please consider the attached patch for inclusion in the binutils CVS
tree.  The patch restores the IA-64 EFI support which is required to
build things such as the Linux boot loader and test programs that run
directly on top of the IA-64 firmware.

As discussed (much ;-) earlier, this required restructuring peigen.c a
bit.  The approach I took is similar to what BFD does for other code
that's (mostly) shared between two different target flavors: the PE+
(pep) format is almost like the regular PE, except for a few fields
that were extended to 64-bits so I renamed peigen.c to peXXigen.c and
this file now gets compiled twice, once with XX defined as "pe" (old
case) and once with XX defined as "pep" (new case).  The related files
peicode.h, libpei.h were updated accordingly.

I also added two fields to the PE-private data structure to allow the
setting of a subsystem id and to allow forcing the minimum section and
file alignment.  Both of these are required for EFI applications.

This patch shouldn't break any other PE targets, so I hope this can be
checked in without any problems.

Note that the IA-32 EFI support, while still there, hasn't been tested
in a while (I can't do that easily right now).  But if need be, it
should be straight-forward to update this target.

Thanks,

	--david

+++ bfd/ChangeLog

2001-02-08  David Mosberger  <davidm@hpl.hp.com>

	* peicode.h (coff_swap_filehdr_out) [COFF_IMAGE_WITH_PE]: Define
	as _bfd_XXi_only_swap_filehdr_out.
	(pe_mkobject) [PEI_FORCE_MINIMUM_ALIGNMENT]: Set
	pe->force_minimum_alignment to TRUE.
	(pe_mkobject) [PEI_TARGET_SUBSYSTEM]: Set pe->target_subsystem to
	PEI_TARGET_SUBSYSTEM.
	(pe_print_private_bfd_data): Call
	_bfd_XX_print_private_bfd_data_common() instead of
	_bfd_pe_print_private_bfd_data_common().
	(pe_bfd_copy_private_bfd_data): Call
	_bfd_XX_bfd_copy_private_bfd_data_common() instead of
	_bfd_pe_bfd_copy_private_bfd_data_common().
	(coff_bfd_copy_private_section_data): Define as
	_bfd_XX_bfd_copy_private_section_data instead of
	_bfd_pe_bfd_copy_private_section_data.
	(coff_get_symbol_info): Define as _bfd_XX_get_symbol_info instead
	of a _bfd_pe_get_symbol_info.

	* peigen.c: Delete.

	* peXXigen.c: Renamed from peigen.c.
	(COFF_WITH_XX): Define this macro (will get expanded into
	COFF_WITH_pep or COFF_WITH_pe, depending on whether this is being
	compiled as peigen.c or pepigen.c.
	[COFF_WITH_pep]: Include "coff/ia64.h" instead of "coff/i386.h" to
	define the canonical PEP structures and definitions.
	(_bfd_XXi_swap_aouthdr_out): If pe->force_minimum_alignment is in
	effect, enforce minimum file and section alignments.  If
	extra->Subsystem is IMAGE_SUBSYSTEM_UNKNOWN, set it to
	pe->target_subsystem (this defaults to IMAGE_SUBSYSTEM_UNKNOWN,
	so, by default, this is a no-op).

	* libpei.h: Rename COFF_WITH_PEP to COFF_WITH_pep.
	(_bfd_XX_bfd_copy_private_bfd_data_common): Add macros to map
	_bfd_XXfoo to _bfd_pepfoo if COFF_WIT_PEP is defined and to
	_bfd_pefoo if it's not defined.  Use these macros to define
	coff swap macros.

	* libcoff.h (pe_tdata): Add members target_subsystem and
	force_minimum_alignment.

	* efi-app-ia64.c (COFF_WITH_pep): Rename COFF_WITH_PEP to
	COFF_WITH_pep.
	(PEI_TARGET_SUBSYSTEM): Rename from PEI_DEFAULT_TARGET_SUBSYSTEM.

	* configure.in (bfd_efi_app_ia64_vec): Use pepigen.lo instead of
	peigen.lo.

	* coff-ia64.c: Rename COFF_WITH_PEP to COFF_WITH_pep.
	(AOUTSZ): Rename PEP64AOUTSZ and PEP64AOUTHDR to PEPAOUTSZ and
	PEPAOUTHDR.

	* Makefile.in (BFD64_BACKENDS): Mention pepigen.lo.
	(BFD64_BACKENDS_CFILES): Mention pepigen.c
	(peigen.c): Add rule to generate from peXXigen.c.
	(pepigen.c): Ditto.
	(pepigen.lo): List dependencies for pepigen.lo.

diff -urN binutils-cvs-010208/bfd/Makefile.in binutils-cvs-010208-lia/bfd/Makefile.in
--- binutils-cvs-010208/bfd/Makefile.in	Thu Feb  8 19:01:14 2001
+++ binutils-cvs-010208-lia/bfd/Makefile.in	Fri Feb  9 00:04:27 2001
@@ -1,6 +1,6 @@
 # Makefile.in generated automatically by automake 1.4 from Makefile.am
 
-# Copyright (C) 1994, 1995-8, 1999 Free Software Foundation, Inc.
+# Copyright (C) 1994, 1995-8, 1999, 2001 Free Software Foundation, Inc.
 # This Makefile.in is free software; the Free Software Foundation
 # gives unlimited permission to copy and/or distribute it,
 # with or without modifications, as long as this notice is preserved.
@@ -536,6 +536,7 @@
 	coff64-rs6000.lo \
 	demo64.lo \
 	efi-app-ia64.lo \
+	pepigen.lo \
 	elf64-x86-64.lo \
 	elf64-alpha.lo \
 	elf64-hppa.lo \
@@ -554,6 +555,7 @@
 	coff64-rs6000.c \
 	demo64.c \
 	efi-app-ia64.c \
+	pepigen.c \
 	elf64-x86-64.c \
 	elf64-alpha.c \
 	elf64-hppa.c \
@@ -1136,6 +1138,16 @@
 $(BFD_BACKENDS): $(BFD_H) $(BFD_H_DEPS) $(LOCAL_H_DEPS)
 $(OPTIONAL_BACKENDS): $(BFD_H) $(BFD_H_DEPS) $(LOCAL_H_DEPS)
 
+peigen.c : peXXigen.c
+	rm -f peigen.c
+	sed -e s/XX/pe/g < $(srcdir)/peXXigen.c > peigen.new
+	mv -f peigen.new peigen.c
+
+pepigen.c : peXXigen.c
+	rm -f pepigen.c
+	sed -e s/XX/pep/g < $(srcdir)/peXXigen.c > pepigen.new
+	mv -f pepigen.new pepigen.c
+
 # Install BFD include file, and others that it needs.
 install-data-local: $(BFD_H)
 	@$(NORMAL_INSTALL)
@@ -1725,6 +1737,9 @@
   libpei.h
 peigen.lo: peigen.c $(INCDIR)/filenames.h $(INCDIR)/coff/internal.h \
   $(INCDIR)/coff/i386.h $(INCDIR)/coff/pe.h libcoff.h \
+  $(INCDIR)/bfdlink.h libpei.h
+pepigen.lo: pepigen.c $(INCDIR)/filenames.h $(INCDIR)/coff/internal.h \
+  $(INCDIR)/coff/ia64.h $(INCDIR)/coff/pe.h libcoff.h \
   $(INCDIR)/bfdlink.h libpei.h
 ppcboot.lo: ppcboot.c $(INCDIR)/filenames.h
 reloc16.lo: reloc16.c $(INCDIR)/filenames.h $(INCDIR)/bfdlink.h \
diff -urN binutils-cvs-010208/bfd/coff-ia64.c binutils-cvs-010208-lia/bfd/coff-ia64.c
--- binutils-cvs-010208/bfd/coff-ia64.c	Wed Jan 31 14:52:10 2001
+++ binutils-cvs-010208-lia/bfd/coff-ia64.c	Fri Feb  9 00:03:05 2001
@@ -1,5 +1,5 @@
 /* BFD back-end for HP/Intel IA-64 COFF files.
-   Copyright 1999 Free Software Foundation, Inc.
+   Copyright 1999, 2001 Free Software Foundation, Inc.
    Contributed by David Mosberger <davidm@hpl.hp.com>
 
 This file is part of BFD, the Binary File Descriptor library.
@@ -21,13 +21,9 @@
 #include "bfd.h"
 #include "sysdep.h"
 #include "libbfd.h"
-
 #include "coff/ia64.h"
-
 #include "coff/internal.h"
-
 #include "coff/pe.h"
-
 #include "libcoff.h"
 
 #define COFF_DEFAULT_SECTION_ALIGNMENT_POWER (2)
@@ -43,10 +39,10 @@
 #define BADMAG(x) IA64BADMAG(x)
 #define IA64 1			/* Customize coffcode.h */
 
-#ifdef COFF_WITH_PEP64
+#ifdef COFF_WITH_pep
 # undef AOUTSZ
-# define AOUTSZ		PEP64AOUTSZ
-# define PEAOUTHDR	PEP64AOUTHDR
+# define AOUTSZ		PEPAOUTSZ
+# define PEAOUTHDR	PEPAOUTHDR
 #endif
 
 #define RTYPE2HOWTO(cache_ptr, dst) \
diff -urN binutils-cvs-010208/bfd/configure.in binutils-cvs-010208-lia/bfd/configure.in
--- binutils-cvs-010208/bfd/configure.in	Wed Jan 31 14:52:17 2001
+++ binutils-cvs-010208-lia/bfd/configure.in	Thu Feb  8 22:12:41 2001
@@ -477,7 +477,7 @@
     b_out_vec_big_host)		tb="$tb bout.lo aout32.lo" ;;
     b_out_vec_little_host)	tb="$tb bout.lo aout32.lo" ;;
     bfd_efi_app_ia32_vec)	tb="$tb efi-app-ia32.lo peigen.lo cofflink.lo" ;;
-    bfd_efi_app_ia64_vec)	tb="$tb efi-app-ia64.lo peigen.lo cofflink.lo"
+    bfd_efi_app_ia64_vec)	tb="$tb efi-app-ia64.lo pepigen.lo cofflink.lo"
   				target64=true ;;
     bfd_elf64_alpha_vec)	tb="$tb elf64-alpha.lo elf64.lo $elf"
 				target64=true ;;
diff -urN binutils-cvs-010208/bfd/efi-app-ia64.c binutils-cvs-010208-lia/bfd/efi-app-ia64.c
--- binutils-cvs-010208/bfd/efi-app-ia64.c	Wed Jan 31 14:52:20 2001
+++ binutils-cvs-010208-lia/bfd/efi-app-ia64.c	Fri Feb  9 00:02:49 2001
@@ -1,5 +1,5 @@
 /* BFD back-end for HP/Intel IA-64 EFI application files.
-   Copyright 1999 Free Software Foundation, Inc.
+   Copyright 1999, 2001 Free Software Foundation, Inc.
    Contributed by David Mosberger <davidm@hpl.hp.com>
 
 This file is part of BFD, the Binary File Descriptor library.
@@ -25,11 +25,11 @@
 #define TARGET_NAME "efi-app-ia64"
 #define COFF_IMAGE_WITH_PE
 #define COFF_WITH_PE
-#define COFF_WITH_PEP64
+#define COFF_WITH_pep
 #define PCRELOFFSET true
 #define TARGET_UNDERSCORE '_'
 #define COFF_LONG_SECTION_NAMES
-#define PEI_DEFAULT_TARGET_SUBSYSTEM	IMAGE_SUBSYSTEM_EFI_APPLICATION
+#define PEI_TARGET_SUBSYSTEM		IMAGE_SUBSYSTEM_EFI_APPLICATION
 #define PEI_FORCE_MINIMUM_ALIGNMENT
 
 #include "coff-ia64.c"
diff -urN binutils-cvs-010208/bfd/libcoff.h binutils-cvs-010208-lia/bfd/libcoff.h
--- binutils-cvs-010208/bfd/libcoff.h	Wed Jan 31 14:52:36 2001
+++ binutils-cvs-010208-lia/bfd/libcoff.h	Fri Feb  9 00:03:58 2001
@@ -1,5 +1,5 @@
 /* BFD COFF object file private structure.
-   Copyright (C) 1990, 91, 92, 93, 94, 95, 96, 97, 98, 1999
+   Copyright (C) 1990, 91, 92, 93, 94, 95, 96, 97, 98, 1999, 2001
    Free Software Foundation, Inc.
    Written by Cygnus Support.
 
@@ -121,6 +121,8 @@
   int has_reloc_section;
   boolean (*in_reloc_p) PARAMS((bfd *, reloc_howto_type *));
   flagword real_flags;
+  int target_subsystem;
+  boolean force_minimum_alignment;
 } pe_data_type;
 
 #define pe_data(bfd)		((bfd)->tdata.pe_obj_data)
diff -urN binutils-cvs-010208/bfd/libpei.h binutils-cvs-010208-lia/bfd/libpei.h
--- binutils-cvs-010208/bfd/libpei.h	Wed Jan 31 14:52:36 2001
+++ binutils-cvs-010208-lia/bfd/libpei.h	Fri Feb  9 00:03:50 2001
@@ -1,5 +1,5 @@
 /* Support for the generic parts of PE/PEI; common header information.
-   Copyright 1995, 1996, 1997, 1998, 1999 Free Software Foundation, Inc.
+   Copyright 1995, 1996, 1997, 1998, 1999, 2001 Free Software Foundation, Inc.
    Written by Cygnus Solutions.
 
 This file is part of BFD, the Binary File Descriptor library.
@@ -192,7 +192,7 @@
 #define PUT_SCNHDR_LNNOPTR bfd_h_put_32
 #endif
 
-#ifdef COFF_WITH_PEP64
+#ifdef COFF_WITH_pep
 
 #define GET_OPTHDR_IMAGE_BASE bfd_h_get_64
 #define PUT_OPTHDR_IMAGE_BASE bfd_h_put_64
@@ -206,7 +206,25 @@
 #define PUT_OPTHDR_SIZE_OF_HEAP_COMMIT bfd_h_put_64
 #define GET_PDATA_ENTRY bfd_get_64
 
-#else /* !COFF_WITH_PEP64 */
+#define _bfd_XX_bfd_copy_private_bfd_data_common	_bfd_pep_bfd_copy_private_bfd_data_common
+#define _bfd_XX_bfd_copy_private_section_data		_bfd_pep_bfd_copy_private_section_data
+#define _bfd_XX_get_symbol_info				_bfd_pep_get_symbol_info
+#define _bfd_XX_only_swap_filehdr_out			_bfd_pep_only_swap_filehdr_out
+#define _bfd_XX_print_private_bfd_data_common		_bfd_pep_print_private_bfd_data_common
+#define _bfd_XXi_final_link_postscript			_bfd_pepi_final_link_postscript
+#define _bfd_XXi_final_link_postscript			_bfd_pepi_final_link_postscript
+#define _bfd_XXi_only_swap_filehdr_out			_bfd_pepi_only_swap_filehdr_out
+#define _bfd_XXi_swap_aouthdr_in			_bfd_pepi_swap_aouthdr_in
+#define _bfd_XXi_swap_aouthdr_out			_bfd_pepi_swap_aouthdr_out
+#define _bfd_XXi_swap_aux_in				_bfd_pepi_swap_aux_in
+#define _bfd_XXi_swap_aux_out				_bfd_pepi_swap_aux_out
+#define _bfd_XXi_swap_lineno_in				_bfd_pepi_swap_lineno_in
+#define _bfd_XXi_swap_lineno_out			_bfd_pepi_swap_lineno_out
+#define _bfd_XXi_swap_scnhdr_out			_bfd_pepi_swap_scnhdr_out
+#define _bfd_XXi_swap_sym_in				_bfd_pepi_swap_sym_in
+#define _bfd_XXi_swap_sym_out				_bfd_pepi_swap_sym_out
+
+#else /* !COFF_WITH_pep */
 
 #define GET_OPTHDR_IMAGE_BASE bfd_h_get_32
 #define PUT_OPTHDR_IMAGE_BASE bfd_h_put_32
@@ -220,7 +238,25 @@
 #define PUT_OPTHDR_SIZE_OF_HEAP_COMMIT bfd_h_put_32
 #define GET_PDATA_ENTRY bfd_get_32
 
-#endif /* !COFF_WITH_PEP64 */
+#define _bfd_XX_bfd_copy_private_bfd_data_common	_bfd_pe_bfd_copy_private_bfd_data_common
+#define _bfd_XX_bfd_copy_private_section_data		_bfd_pe_bfd_copy_private_section_data
+#define _bfd_XX_get_symbol_info				_bfd_pe_get_symbol_info
+#define _bfd_XX_only_swap_filehdr_out			_bfd_pe_only_swap_filehdr_out
+#define _bfd_XX_print_private_bfd_data_common		_bfd_pe_print_private_bfd_data_common
+#define _bfd_XXi_final_link_postscript			_bfd_pei_final_link_postscript
+#define _bfd_XXi_final_link_postscript			_bfd_pei_final_link_postscript
+#define _bfd_XXi_only_swap_filehdr_out			_bfd_pei_only_swap_filehdr_out
+#define _bfd_XXi_swap_aouthdr_in			_bfd_pei_swap_aouthdr_in
+#define _bfd_XXi_swap_aouthdr_out			_bfd_pei_swap_aouthdr_out
+#define _bfd_XXi_swap_aux_in				_bfd_pei_swap_aux_in
+#define _bfd_XXi_swap_aux_out				_bfd_pei_swap_aux_out
+#define _bfd_XXi_swap_lineno_in				_bfd_pei_swap_lineno_in
+#define _bfd_XXi_swap_lineno_out			_bfd_pei_swap_lineno_out
+#define _bfd_XXi_swap_scnhdr_out			_bfd_pei_swap_scnhdr_out
+#define _bfd_XXi_swap_sym_in				_bfd_pei_swap_sym_in
+#define _bfd_XXi_swap_sym_out				_bfd_pei_swap_sym_out
+
+#endif /* !COFF_WITH_pep */
 
 /* These functions are architecture dependent, and are in peicode.h:
    coff_swap_reloc_in
@@ -234,51 +270,51 @@
    implementations architecture types, and actually appear in
    peigen.c.  */
 
-void _bfd_pei_swap_sym_in PARAMS ((bfd*, PTR, PTR));
-#define coff_swap_sym_in _bfd_pei_swap_sym_in
+void _bfd_XXi_swap_sym_in PARAMS ((bfd*, PTR, PTR));
+#define coff_swap_sym_in _bfd_XXi_swap_sym_in
 
-unsigned int _bfd_pei_swap_sym_out PARAMS ((bfd*, PTR, PTR));
-#define coff_swap_sym_out _bfd_pei_swap_sym_out
+unsigned int _bfd_XXi_swap_sym_out PARAMS ((bfd*, PTR, PTR));
+#define coff_swap_sym_out _bfd_XXi_swap_sym_out
 
-void _bfd_pei_swap_aux_in PARAMS ((bfd *, PTR, int, int, int, int, PTR));
-#define coff_swap_aux_in _bfd_pei_swap_aux_in
+void _bfd_XXi_swap_aux_in PARAMS ((bfd *, PTR, int, int, int, int, PTR));
+#define coff_swap_aux_in _bfd_XXi_swap_aux_in
 
-unsigned int _bfd_pei_swap_aux_out \
+unsigned int _bfd_XXi_swap_aux_out \
   PARAMS ((bfd *, PTR, int, int, int, int, PTR));
-#define coff_swap_aux_out _bfd_pei_swap_aux_out
+#define coff_swap_aux_out _bfd_XXi_swap_aux_out
 
-void _bfd_pei_swap_lineno_in PARAMS ((bfd*, PTR, PTR));
-#define coff_swap_lineno_in _bfd_pei_swap_lineno_in
+void _bfd_XXi_swap_lineno_in PARAMS ((bfd*, PTR, PTR));
+#define coff_swap_lineno_in _bfd_XXi_swap_lineno_in
 
-unsigned int _bfd_pei_swap_lineno_out PARAMS ((bfd*, PTR, PTR));
-#define coff_swap_lineno_out _bfd_pei_swap_lineno_out
+unsigned int _bfd_XXi_swap_lineno_out PARAMS ((bfd*, PTR, PTR));
+#define coff_swap_lineno_out _bfd_XXi_swap_lineno_out
 
-void _bfd_pei_swap_aouthdr_in PARAMS ((bfd*, PTR, PTR));
-#define coff_swap_aouthdr_in _bfd_pei_swap_aouthdr_in
+void _bfd_XXi_swap_aouthdr_in PARAMS ((bfd*, PTR, PTR));
+#define coff_swap_aouthdr_in _bfd_XXi_swap_aouthdr_in
 
-unsigned int _bfd_pei_swap_aouthdr_out PARAMS ((bfd *, PTR, PTR));
-#define coff_swap_aouthdr_out _bfd_pei_swap_aouthdr_out
+unsigned int _bfd_XXi_swap_aouthdr_out PARAMS ((bfd *, PTR, PTR));
+#define coff_swap_aouthdr_out _bfd_XXi_swap_aouthdr_out
 
-unsigned int _bfd_pei_swap_scnhdr_out PARAMS ((bfd *, PTR, PTR));
-#define coff_swap_scnhdr_out _bfd_pei_swap_scnhdr_out
+unsigned int _bfd_XXi_swap_scnhdr_out PARAMS ((bfd *, PTR, PTR));
+#define coff_swap_scnhdr_out _bfd_XXi_swap_scnhdr_out
 
-boolean _bfd_pe_print_private_bfd_data_common PARAMS ((bfd *, PTR));
+boolean _bfd_XX_print_private_bfd_data_common PARAMS ((bfd *, PTR));
 
-boolean _bfd_pe_bfd_copy_private_bfd_data_common PARAMS ((bfd *, bfd *));
+boolean _bfd_XX_bfd_copy_private_bfd_data_common PARAMS ((bfd *, bfd *));
 
-void _bfd_pe_get_symbol_info PARAMS ((bfd *, asymbol *, symbol_info *));
+void _bfd_XX_get_symbol_info PARAMS ((bfd *, asymbol *, symbol_info *));
 
-boolean _bfd_pei_final_link_postscript
+boolean _bfd_XXi_final_link_postscript
   PARAMS ((bfd *, struct coff_final_link_info *));
 
 #ifndef coff_final_link_postscript
-#define coff_final_link_postscript _bfd_pei_final_link_postscript
+#define coff_final_link_postscript _bfd_XXi_final_link_postscript
 #endif
 /* The following are needed only for ONE of pe or pei, but don't
    otherwise vary; peicode.h fixes up ifdefs but we provide the
    prototype.  */
 
-unsigned int _bfd_pe_only_swap_filehdr_out PARAMS ((bfd*, PTR, PTR));
-unsigned int _bfd_pei_only_swap_filehdr_out PARAMS ((bfd*, PTR, PTR));
-boolean _bfd_pe_bfd_copy_private_section_data
+unsigned int _bfd_XX_only_swap_filehdr_out PARAMS ((bfd*, PTR, PTR));
+unsigned int _bfd_XXi_only_swap_filehdr_out PARAMS ((bfd*, PTR, PTR));
+boolean _bfd_XX_bfd_copy_private_section_data
   PARAMS ((bfd *, asection *, bfd *, asection *));
diff -urN binutils-cvs-010208/bfd/peXXigen.c binutils-cvs-010208-lia/bfd/peXXigen.c
--- binutils-cvs-010208/bfd/peXXigen.c	Wed Dec 31 16:00:00 1969
+++ binutils-cvs-010208-lia/bfd/peXXigen.c	Fri Feb  9 00:03:39 2001
@@ -0,0 +1,2040 @@
+/* Support for the generic parts of PE/PEI; the common executable parts.
+   Copyright 1995, 96, 97, 98, 99, 2000, 2001 Free Software Foundation, Inc.
+   Written by Cygnus Solutions.
+
+This file is part of BFD, the Binary File Descriptor library.
+
+This program is free software; you can redistribute it and/or modify
+it under the terms of the GNU General Public License as published by
+the Free Software Foundation; either version 2 of the License, or
+(at your option) any later version.
+
+This program is distributed in the hope that it will be useful,
+but WITHOUT ANY WARRANTY; without even the implied warranty of
+MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+GNU General Public License for more details.
+
+You should have received a copy of the GNU General Public License
+along with this program; if not, write to the Free Software
+Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */
+
+/* Most of this hacked by Steve Chamberlain <sac@cygnus.com>.
+
+   PE/PEI rearrangement (and code added): Donn Terry
+					  Softway Systems, Inc.
+*/
+
+/* Hey look, some documentation [and in a place you expect to find it]!
+
+   The main reference for the pei format is "Microsoft Portable Executable
+   and Common Object File Format Specification 4.1".  Get it if you need to
+   do some serious hacking on this code.
+
+   Another reference:
+   "Peering Inside the PE: A Tour of the Win32 Portable Executable
+   File Format", MSJ 1994, Volume 9.
+
+   The *sole* difference between the pe format and the pei format is that the
+   latter has an MSDOS 2.0 .exe header on the front that prints the message
+   "This app must be run under Windows." (or some such).
+   (FIXME: Whether that statement is *really* true or not is unknown.
+   Are there more subtle differences between pe and pei formats?
+   For now assume there aren't.  If you find one, then for God sakes
+   document it here!)
+
+   The Microsoft docs use the word "image" instead of "executable" because
+   the former can also refer to a DLL (shared library).  Confusion can arise
+   because the `i' in `pei' also refers to "image".  The `pe' format can
+   also create images (i.e. executables), it's just that to run on a win32
+   system you need to use the pei format.
+
+   FIXME: Please add more docs here so the next poor fool that has to hack
+   on this code has a chance of getting something accomplished without
+   wasting too much time.
+*/
+
+/* This expands into COFF_WITH_pe or COFF_WITH_pep depending on whether
+   we're compiling for straight PE or PE+.  */
+#define COFF_WITH_XX
+
+#include "bfd.h"
+#include "sysdep.h"
+#include "libbfd.h"
+#include "coff/internal.h"
+
+/* NOTE: it's strange to be including an architecture specific header
+   in what's supposed to be general (to PE/PEI) code.  However, that's
+   where the definitions are, and they don't vary per architecture
+   within PE/PEI, so we get them from there.  FIXME: The lack of
+   variance is an assumption which may prove to be incorrect if new
+   PE/PEI targets are created.  */
+#ifdef COFF_WITH_pep
+# include "coff/ia64.h"
+#else
+# include "coff/i386.h"
+#endif
+
+#include "coff/pe.h"
+#include "libcoff.h"
+#include "libpei.h"
+
+#ifdef COFF_WITH_pep
+# undef AOUTSZ
+# define AOUTSZ		PEPAOUTSZ
+# define PEAOUTHDR	PEPAOUTHDR
+#endif
+
+/* FIXME: This file has various tests of POWERPC_LE_PE.  Those tests
+   worked when the code was in peicode.h, but no longer work now that
+   the code is in peigen.c.  PowerPC NT is said to be dead.  If
+   anybody wants to revive the code, you will have to figure out how
+   to handle those issues.  */
+
+static void add_data_entry
+  PARAMS ((bfd *, struct internal_extra_pe_aouthdr *, int, char *, bfd_vma));
+static boolean pe_print_pdata PARAMS ((bfd *, PTR));
+static boolean pe_print_reloc PARAMS ((bfd *, PTR));
+
+/**********************************************************************/
+
+void
+_bfd_XXi_swap_sym_in (abfd, ext1, in1)
+     bfd *abfd;
+     PTR ext1;
+     PTR in1;
+{
+  SYMENT *ext = (SYMENT *) ext1;
+  struct internal_syment *in = (struct internal_syment *) in1;
+
+  if (ext->e.e_name[0] = 0)
+    {
+      in->_n._n_n._n_zeroes = 0;
+      in->_n._n_n._n_offset +	bfd_h_get_32 (abfd, (bfd_byte *) ext->e.e.e_offset);
+    }
+  else
+    {
+      memcpy (in->_n._n_name, ext->e.e_name, SYMNMLEN);
+    }
+
+  in->n_value = bfd_h_get_32 (abfd, (bfd_byte *) ext->e_value);
+  in->n_scnum = bfd_h_get_16 (abfd, (bfd_byte *) ext->e_scnum);
+  if (sizeof (ext->e_type) = 2)
+    {
+      in->n_type = bfd_h_get_16 (abfd, (bfd_byte *) ext->e_type);
+    }
+  else
+    {
+      in->n_type = bfd_h_get_32 (abfd, (bfd_byte *) ext->e_type);
+    }
+  in->n_sclass = bfd_h_get_8 (abfd, ext->e_sclass);
+  in->n_numaux = bfd_h_get_8 (abfd, ext->e_numaux);
+
+#ifndef STRICT_PE_FORMAT
+  /* This is for Gnu-created DLLs.  */
+
+  /* The section symbols for the .idata$ sections have class 0x68
+     (C_SECTION), which MS documentation indicates is a section
+     symbol.  Unfortunately, the value field in the symbol is simply a
+     copy of the .idata section's flags rather than something useful.
+     When these symbols are encountered, change the value to 0 so that
+     they will be handled somewhat correctly in the bfd code.  */
+  if (in->n_sclass = C_SECTION)
+    {
+      in->n_value = 0x0;
+
+#if 0
+      /* FIXME: This is clearly wrong.  The problem seems to be that
+         undefined C_SECTION symbols appear in the first object of a
+         MS generated .lib file, and the symbols are not defined
+         anywhere.  */
+      in->n_scnum = 1;
+
+      /* I have tried setting the class to 3 and using the following
+	 to set the section number.  This will put the address of the
+	 pointer to the string kernel32.dll at addresses 0 and 0x10
+	 off start of idata section which is not correct.  */
+#if 0
+      if (strcmp (in->_n._n_name, ".idata$4") = 0)
+	in->n_scnum = 3;
+      else
+	in->n_scnum = 2;
+#endif
+#else
+      /* Create synthetic empty sections as needed.  DJ */
+      if (in->n_scnum = 0)
+	{
+	  asection *sec;
+	  for (sec = abfd->sections; sec; sec = sec->next)
+	    {
+	      if (strcmp (sec->name, in->n_name) = 0)
+		{
+		  in->n_scnum = sec->target_index;
+		  break;
+		}
+	    }
+	}
+      if (in->n_scnum = 0)
+	{
+	  int unused_section_number = 0;
+	  asection *sec;
+	  char *name;
+	  for (sec = abfd->sections; sec; sec = sec->next)
+	    if (unused_section_number <= sec->target_index)
+	      unused_section_number = sec->target_index + 1;
+
+	  name = bfd_alloc (abfd, strlen (in->n_name) + 10);
+	  if (name = NULL)
+	    return;
+	  strcpy (name, in->n_name);
+	  sec = bfd_make_section_anyway (abfd, name);
+
+	  sec->vma = 0;
+	  sec->lma = 0;
+	  sec->_cooked_size = 0;
+	  sec->_raw_size = 0;
+	  sec->filepos = 0;
+	  sec->rel_filepos = 0;
+	  sec->reloc_count = 0;
+	  sec->line_filepos = 0;
+	  sec->lineno_count = 0;
+	  sec->userdata = NULL;
+	  sec->next = (asection *) NULL;
+	  sec->flags = 0;
+	  sec->alignment_power = 2;
+	  sec->flags = SEC_HAS_CONTENTS | SEC_ALLOC | SEC_DATA | SEC_LOAD;
+
+	  sec->target_index = unused_section_number;
+
+	  in->n_scnum = unused_section_number;
+	}
+      in->n_sclass = C_STAT;
+#endif
+    }
+#endif
+
+#ifdef coff_swap_sym_in_hook
+  /* This won't work in peigen.c, but since it's for PPC PE, it's not
+     worth fixing.  */
+  coff_swap_sym_in_hook (abfd, ext1, in1);
+#endif
+}
+
+unsigned int
+_bfd_XXi_swap_sym_out (abfd, inp, extp)
+     bfd       *abfd;
+     PTR	inp;
+     PTR	extp;
+{
+  struct internal_syment *in = (struct internal_syment *) inp;
+  SYMENT *ext = (SYMENT *) extp;
+  if (in->_n._n_name[0] = 0)
+    {
+      bfd_h_put_32 (abfd, 0, (bfd_byte *) ext->e.e.e_zeroes);
+      bfd_h_put_32 (abfd, in->_n._n_n._n_offset, (bfd_byte *) ext->e.e.e_offset);
+    }
+  else
+    {
+      memcpy (ext->e.e_name, in->_n._n_name, SYMNMLEN);
+    }
+
+  bfd_h_put_32 (abfd, in->n_value, (bfd_byte *) ext->e_value);
+  bfd_h_put_16 (abfd, in->n_scnum, (bfd_byte *) ext->e_scnum);
+  if (sizeof (ext->e_type) = 2)
+    {
+      bfd_h_put_16 (abfd, in->n_type, (bfd_byte *) ext->e_type);
+    }
+  else
+    {
+      bfd_h_put_32 (abfd, in->n_type, (bfd_byte *) ext->e_type);
+    }
+  bfd_h_put_8 (abfd, in->n_sclass, ext->e_sclass);
+  bfd_h_put_8 (abfd, in->n_numaux, ext->e_numaux);
+
+  return SYMESZ;
+}
+
+void
+_bfd_XXi_swap_aux_in (abfd, ext1, type, class, indx, numaux, in1)
+     bfd            *abfd;
+     PTR	     ext1;
+     int             type;
+     int             class;
+     int	     indx ATTRIBUTE_UNUSED;
+     int	     numaux ATTRIBUTE_UNUSED;
+     PTR 	     in1;
+{
+  AUXENT *ext = (AUXENT *) ext1;
+  union internal_auxent *in = (union internal_auxent *) in1;
+
+  switch (class)
+    {
+    case C_FILE:
+      if (ext->x_file.x_fname[0] = 0)
+	{
+	  in->x_file.x_n.x_zeroes = 0;
+	  in->x_file.x_n.x_offset +	    bfd_h_get_32 (abfd, (bfd_byte *) ext->x_file.x_n.x_offset);
+	}
+      else
+	{
+	  memcpy (in->x_file.x_fname, ext->x_file.x_fname, FILNMLEN);
+	}
+      return;
+
+    case C_STAT:
+    case C_LEAFSTAT:
+    case C_HIDDEN:
+      if (type = T_NULL)
+	{
+	  in->x_scn.x_scnlen = GET_SCN_SCNLEN (abfd, ext);
+	  in->x_scn.x_nreloc = GET_SCN_NRELOC (abfd, ext);
+	  in->x_scn.x_nlinno = GET_SCN_NLINNO (abfd, ext);
+	  in->x_scn.x_checksum +	    bfd_h_get_32 (abfd, (bfd_byte *) ext->x_scn.x_checksum);
+	  in->x_scn.x_associated +	    bfd_h_get_16 (abfd, (bfd_byte *) ext->x_scn.x_associated);
+	  in->x_scn.x_comdat +	    bfd_h_get_8 (abfd, (bfd_byte *) ext->x_scn.x_comdat);
+	  return;
+	}
+      break;
+    }
+
+  in->x_sym.x_tagndx.l = bfd_h_get_32 (abfd, (bfd_byte *) ext->x_sym.x_tagndx);
+  in->x_sym.x_tvndx = bfd_h_get_16 (abfd, (bfd_byte *) ext->x_sym.x_tvndx);
+
+  if (class = C_BLOCK || class = C_FCN || ISFCN (type) || ISTAG (class))
+    {
+      in->x_sym.x_fcnary.x_fcn.x_lnnoptr = GET_FCN_LNNOPTR (abfd, ext);
+      in->x_sym.x_fcnary.x_fcn.x_endndx.l = GET_FCN_ENDNDX (abfd, ext);
+    }
+  else
+    {
+      in->x_sym.x_fcnary.x_ary.x_dimen[0] +	bfd_h_get_16 (abfd, (bfd_byte *) ext->x_sym.x_fcnary.x_ary.x_dimen[0]);
+      in->x_sym.x_fcnary.x_ary.x_dimen[1] +	bfd_h_get_16 (abfd, (bfd_byte *) ext->x_sym.x_fcnary.x_ary.x_dimen[1]);
+      in->x_sym.x_fcnary.x_ary.x_dimen[2] +	bfd_h_get_16 (abfd, (bfd_byte *) ext->x_sym.x_fcnary.x_ary.x_dimen[2]);
+      in->x_sym.x_fcnary.x_ary.x_dimen[3] +	bfd_h_get_16 (abfd, (bfd_byte *) ext->x_sym.x_fcnary.x_ary.x_dimen[3]);
+    }
+
+  if (ISFCN (type))
+    {
+      in->x_sym.x_misc.x_fsize +	bfd_h_get_32 (abfd, (bfd_byte *) ext->x_sym.x_misc.x_fsize);
+    }
+  else
+    {
+      in->x_sym.x_misc.x_lnsz.x_lnno = GET_LNSZ_LNNO (abfd, ext);
+      in->x_sym.x_misc.x_lnsz.x_size = GET_LNSZ_SIZE (abfd, ext);
+    }
+}
+
+unsigned int
+_bfd_XXi_swap_aux_out (abfd, inp, type, class, indx, numaux, extp)
+     bfd  *abfd;
+     PTR   inp;
+     int   type;
+     int   class;
+     int   indx ATTRIBUTE_UNUSED;
+     int   numaux ATTRIBUTE_UNUSED;
+     PTR   extp;
+{
+  union internal_auxent *in = (union internal_auxent *) inp;
+  AUXENT *ext = (AUXENT *) extp;
+
+  memset ((PTR) ext, 0, AUXESZ);
+  switch (class)
+    {
+    case C_FILE:
+      if (in->x_file.x_fname[0] = 0)
+	{
+	  bfd_h_put_32 (abfd, 0, (bfd_byte *) ext->x_file.x_n.x_zeroes);
+	  bfd_h_put_32 (abfd,
+			in->x_file.x_n.x_offset,
+			(bfd_byte *) ext->x_file.x_n.x_offset);
+	}
+      else
+	{
+	  memcpy (ext->x_file.x_fname, in->x_file.x_fname, FILNMLEN);
+	}
+      return AUXESZ;
+
+    case C_STAT:
+    case C_LEAFSTAT:
+    case C_HIDDEN:
+      if (type = T_NULL)
+	{
+	  PUT_SCN_SCNLEN (abfd, in->x_scn.x_scnlen, ext);
+	  PUT_SCN_NRELOC (abfd, in->x_scn.x_nreloc, ext);
+	  PUT_SCN_NLINNO (abfd, in->x_scn.x_nlinno, ext);
+	  bfd_h_put_32 (abfd, in->x_scn.x_checksum,
+			(bfd_byte *) ext->x_scn.x_checksum);
+	  bfd_h_put_16 (abfd, in->x_scn.x_associated,
+			(bfd_byte *) ext->x_scn.x_associated);
+	  bfd_h_put_8 (abfd, in->x_scn.x_comdat,
+		       (bfd_byte *) ext->x_scn.x_comdat);
+	  return AUXESZ;
+	}
+      break;
+    }
+
+  bfd_h_put_32 (abfd, in->x_sym.x_tagndx.l, (bfd_byte *) ext->x_sym.x_tagndx);
+  bfd_h_put_16 (abfd, in->x_sym.x_tvndx, (bfd_byte *) ext->x_sym.x_tvndx);
+
+  if (class = C_BLOCK || class = C_FCN || ISFCN (type) || ISTAG (class))
+    {
+      PUT_FCN_LNNOPTR (abfd, in->x_sym.x_fcnary.x_fcn.x_lnnoptr,  ext);
+      PUT_FCN_ENDNDX  (abfd, in->x_sym.x_fcnary.x_fcn.x_endndx.l, ext);
+    }
+  else
+    {
+      bfd_h_put_16 (abfd, in->x_sym.x_fcnary.x_ary.x_dimen[0],
+		    (bfd_byte *) ext->x_sym.x_fcnary.x_ary.x_dimen[0]);
+      bfd_h_put_16 (abfd, in->x_sym.x_fcnary.x_ary.x_dimen[1],
+		    (bfd_byte *) ext->x_sym.x_fcnary.x_ary.x_dimen[1]);
+      bfd_h_put_16 (abfd, in->x_sym.x_fcnary.x_ary.x_dimen[2],
+		    (bfd_byte *) ext->x_sym.x_fcnary.x_ary.x_dimen[2]);
+      bfd_h_put_16 (abfd, in->x_sym.x_fcnary.x_ary.x_dimen[3],
+		    (bfd_byte *) ext->x_sym.x_fcnary.x_ary.x_dimen[3]);
+    }
+
+  if (ISFCN (type))
+    bfd_h_put_32 (abfd, in->x_sym.x_misc.x_fsize,
+		  (bfd_byte *) ext->x_sym.x_misc.x_fsize);
+  else
+    {
+      PUT_LNSZ_LNNO (abfd, in->x_sym.x_misc.x_lnsz.x_lnno, ext);
+      PUT_LNSZ_SIZE (abfd, in->x_sym.x_misc.x_lnsz.x_size, ext);
+    }
+
+  return AUXESZ;
+}
+
+void
+_bfd_XXi_swap_lineno_in (abfd, ext1, in1)
+     bfd *abfd;
+     PTR ext1;
+     PTR in1;
+{
+  LINENO *ext = (LINENO *) ext1;
+  struct internal_lineno *in = (struct internal_lineno *) in1;
+
+  in->l_addr.l_symndx = bfd_h_get_32 (abfd, (bfd_byte *) ext->l_addr.l_symndx);
+  in->l_lnno = GET_LINENO_LNNO (abfd, ext);
+}
+
+unsigned int
+_bfd_XXi_swap_lineno_out (abfd, inp, outp)
+     bfd       *abfd;
+     PTR	inp;
+     PTR	outp;
+{
+  struct internal_lineno *in = (struct internal_lineno *) inp;
+  struct external_lineno *ext = (struct external_lineno *) outp;
+  bfd_h_put_32 (abfd, in->l_addr.l_symndx, (bfd_byte *)
+	  ext->l_addr.l_symndx);
+
+  PUT_LINENO_LNNO (abfd, in->l_lnno, ext);
+  return LINESZ;
+}
+
+void
+_bfd_XXi_swap_aouthdr_in (abfd, aouthdr_ext1, aouthdr_int1)
+     bfd *abfd;
+     PTR aouthdr_ext1;
+     PTR aouthdr_int1;
+{
+  struct internal_extra_pe_aouthdr *a;
+  PEAOUTHDR *src = (PEAOUTHDR *) (aouthdr_ext1);
+  AOUTHDR        *aouthdr_ext = (AOUTHDR *) aouthdr_ext1;
+  struct internal_aouthdr *aouthdr_int = (struct internal_aouthdr *)aouthdr_int1;
+
+  aouthdr_int->magic = bfd_h_get_16 (abfd, (bfd_byte *) aouthdr_ext->magic);
+  aouthdr_int->vstamp = bfd_h_get_16 (abfd, (bfd_byte *) aouthdr_ext->vstamp);
+  aouthdr_int->tsize +    GET_AOUTHDR_TSIZE (abfd, (bfd_byte *) aouthdr_ext->tsize);
+  aouthdr_int->dsize +    GET_AOUTHDR_DSIZE (abfd, (bfd_byte *) aouthdr_ext->dsize);
+  aouthdr_int->bsize +    GET_AOUTHDR_BSIZE (abfd, (bfd_byte *) aouthdr_ext->bsize);
+  aouthdr_int->entry +    GET_AOUTHDR_ENTRY (abfd, (bfd_byte *) aouthdr_ext->entry);
+  aouthdr_int->text_start +    GET_AOUTHDR_TEXT_START (abfd, (bfd_byte *) aouthdr_ext->text_start);
+#ifndef COFF_WITH_pep
+  /* PE32+ does not have data_start member! */
+  aouthdr_int->data_start +    GET_AOUTHDR_DATA_START (abfd, (bfd_byte *) aouthdr_ext->data_start);
+#endif
+
+  a = &aouthdr_int->pe;
+  a->ImageBase = GET_OPTHDR_IMAGE_BASE (abfd, (bfd_byte *) src->ImageBase);
+  a->SectionAlignment = bfd_h_get_32 (abfd, (bfd_byte *) src->SectionAlignment);
+  a->FileAlignment = bfd_h_get_32 (abfd, (bfd_byte *) src->FileAlignment);
+  a->MajorOperatingSystemVersion +    bfd_h_get_16 (abfd, (bfd_byte *) src->MajorOperatingSystemVersion);
+  a->MinorOperatingSystemVersion +    bfd_h_get_16 (abfd, (bfd_byte *) src->MinorOperatingSystemVersion);
+  a->MajorImageVersion = bfd_h_get_16 (abfd, (bfd_byte *) src->MajorImageVersion);
+  a->MinorImageVersion = bfd_h_get_16 (abfd, (bfd_byte *) src->MinorImageVersion);
+  a->MajorSubsystemVersion = bfd_h_get_16 (abfd, (bfd_byte *) src->MajorSubsystemVersion);
+  a->MinorSubsystemVersion = bfd_h_get_16 (abfd, (bfd_byte *) src->MinorSubsystemVersion);
+  a->Reserved1 = bfd_h_get_32 (abfd, (bfd_byte *) src->Reserved1);
+  a->SizeOfImage = bfd_h_get_32 (abfd, (bfd_byte *) src->SizeOfImage);
+  a->SizeOfHeaders = bfd_h_get_32 (abfd, (bfd_byte *) src->SizeOfHeaders);
+  a->CheckSum = bfd_h_get_32 (abfd, (bfd_byte *) src->CheckSum);
+  a->Subsystem = bfd_h_get_16 (abfd, (bfd_byte *) src->Subsystem);
+  a->DllCharacteristics = bfd_h_get_16 (abfd, (bfd_byte *) src->DllCharacteristics);
+  a->SizeOfStackReserve = GET_OPTHDR_SIZE_OF_STACK_RESERVE (abfd, (bfd_byte *) src->SizeOfStackReserve);
+  a->SizeOfStackCommit = GET_OPTHDR_SIZE_OF_STACK_COMMIT (abfd, (bfd_byte *) src->SizeOfStackCommit);
+  a->SizeOfHeapReserve = GET_OPTHDR_SIZE_OF_HEAP_RESERVE (abfd, (bfd_byte *) src->SizeOfHeapReserve);
+  a->SizeOfHeapCommit = GET_OPTHDR_SIZE_OF_HEAP_COMMIT (abfd, (bfd_byte *) src->SizeOfHeapCommit);
+  a->LoaderFlags = bfd_h_get_32 (abfd, (bfd_byte *) src->LoaderFlags);
+  a->NumberOfRvaAndSizes = bfd_h_get_32 (abfd, (bfd_byte *) src->NumberOfRvaAndSizes);
+
+  {
+    int idx;
+    for (idx = 0; idx < 16; idx++)
+      {
+        /* If data directory is empty, rva also should be 0.  */
+	int size +	  bfd_h_get_32 (abfd, (bfd_byte *) src->DataDirectory[idx][1]);
+	a->DataDirectory[idx].Size = size;
+
+	if (size)
+	  {
+	    a->DataDirectory[idx].VirtualAddress +	      bfd_h_get_32 (abfd, (bfd_byte *) src->DataDirectory[idx][0]);
+	  }
+	else
+	  a->DataDirectory[idx].VirtualAddress = 0;
+      }
+  }
+
+  if (aouthdr_int->entry)
+    {
+      aouthdr_int->entry += a->ImageBase;
+#ifndef COFF_WITH_pep
+      aouthdr_int->entry &= 0xffffffff;
+#endif
+    }
+  if (aouthdr_int->tsize)
+    {
+      aouthdr_int->text_start += a->ImageBase;
+#ifndef COFF_WITH_pep
+      aouthdr_int->text_start &= 0xffffffff;
+#endif
+    }
+#ifndef COFF_WITH_pep
+  /* PE32+ does not have data_start member! */
+  if (aouthdr_int->dsize)
+    {
+      aouthdr_int->data_start += a->ImageBase;
+      aouthdr_int->data_start &= 0xffffffff;
+    }
+#endif
+
+#ifdef POWERPC_LE_PE
+  /* These three fields are normally set up by ppc_relocate_section.
+     In the case of reading a file in, we can pick them up from the
+     DataDirectory.  */
+  first_thunk_address = a->DataDirectory[12].VirtualAddress;
+  thunk_size = a->DataDirectory[12].Size;
+  import_table_size = a->DataDirectory[1].Size;
+#endif
+
+}
+
+/* A support function for below.  */
+
+static void
+add_data_entry (abfd, aout, idx, name, base)
+     bfd *abfd;
+     struct internal_extra_pe_aouthdr *aout;
+     int idx;
+     char *name;
+     bfd_vma base;
+{
+  asection *sec = bfd_get_section_by_name (abfd, name);
+
+  /* add import directory information if it exists */
+  if ((sec != NULL)
+      && (coff_section_data (abfd, sec) != NULL)
+      && (pei_section_data (abfd, sec) != NULL))
+    {
+      /* If data directory is empty, rva also should be 0 */
+      int size = pei_section_data (abfd, sec)->virt_size;
+      aout->DataDirectory[idx].Size = size;
+
+      if (size)
+	{
+	  aout->DataDirectory[idx].VirtualAddress +	    (sec->vma - base) & 0xffffffff;
+	  sec->flags |= SEC_DATA;
+	}
+    }
+}
+
+unsigned int
+_bfd_XXi_swap_aouthdr_out (abfd, in, out)
+     bfd       *abfd;
+     PTR	in;
+     PTR	out;
+{
+  struct internal_aouthdr *aouthdr_in = (struct internal_aouthdr *) in;
+  pe_data_type *pe = pe_data (abfd);
+  struct internal_extra_pe_aouthdr *extra = &pe->pe_opthdr;
+  PEAOUTHDR *aouthdr_out = (PEAOUTHDR *) out;
+  bfd_vma sa, fa, ib;
+
+  if (pe->force_minimum_alignment)
+    {
+      if (!extra->FileAlignment)
+	extra->FileAlignment = PE_DEF_FILE_ALIGNMENT;
+      if (!extra->SectionAlignment)
+	extra->SectionAlignment = PE_DEF_SECTION_ALIGNMENT;
+    }
+
+  if (extra->Subsystem = IMAGE_SUBSYSTEM_UNKNOWN)
+    extra->Subsystem = pe->target_subsystem;
+
+  sa = extra->SectionAlignment;
+  fa = extra->FileAlignment;
+  ib = extra->ImageBase;
+
+  if (aouthdr_in->tsize)
+    {
+      aouthdr_in->text_start -= ib;
+#ifndef COFF_WITH_pep
+      aouthdr_in->text_start &= 0xffffffff;
+#endif
+    }
+  if (aouthdr_in->dsize)
+    {
+      aouthdr_in->data_start -= ib;
+#ifndef COFF_WITH_pep
+      aouthdr_in->data_start &= 0xffffffff;
+#endif
+    }
+  if (aouthdr_in->entry)
+    {
+      aouthdr_in->entry -= ib;
+#ifndef COFF_WITH_pep
+      aouthdr_in->entry &= 0xffffffff;
+#endif
+    }
+
+#define FA(x) (((x) + fa -1 ) & (- fa))
+#define SA(x) (((x) + sa -1 ) & (- sa))
+
+  /* We like to have the sizes aligned.  */
+
+  aouthdr_in->bsize = FA (aouthdr_in->bsize);
+
+  extra->NumberOfRvaAndSizes = IMAGE_NUMBEROF_DIRECTORY_ENTRIES;
+
+  /* first null out all data directory entries ..  */
+  memset (extra->DataDirectory, sizeof (extra->DataDirectory), 0);
+
+  add_data_entry (abfd, extra, 0, ".edata", ib);
+
+  /* Don't call add_data_entry for .idata$2 or .idata$5.  It's done in
+     bfd_coff_final_link where all the required information is
+     available.  */
+
+  /* However, until other .idata fixes are made (pending patch), the
+     entry for .idata is needed for backwards compatability.  FIXME.  */
+  add_data_entry (abfd, extra, 1, ".idata", ib);
+
+  add_data_entry (abfd, extra, 2, ".rsrc", ib);
+
+  add_data_entry (abfd, extra, 3, ".pdata", ib);
+
+  /* For some reason, the virtual size (which is what's set by
+     add_data_entry) for .reloc is not the same as the size recorded
+     in this slot by MSVC; it doesn't seem to cause problems (so far),
+     but since it's the best we've got, use it.  It does do the right
+     thing for .pdata.  */
+  if (pe->has_reloc_section)
+    add_data_entry (abfd, extra, 5, ".reloc", ib);
+
+  {
+    asection *sec;
+    bfd_vma dsize = 0;
+    bfd_vma isize = SA(abfd->sections->filepos);
+    bfd_vma tsize = 0;
+
+    for (sec = abfd->sections; sec; sec = sec->next)
+      {
+	int rounded = FA(sec->_raw_size);
+
+	if (sec->flags & SEC_DATA)
+	  dsize += rounded;
+	if (sec->flags & SEC_CODE)
+	  tsize += rounded;
+	/* The image size is the total VIRTUAL size (which is what is
+	   in the virt_size field).  Files have been seen (from MSVC
+	   5.0 link.exe) where the file size of the .data segment is
+	   quite small compared to the virtual size.  Without this
+	   fix, strip munges the file.  */
+	isize += SA (FA (pei_section_data (abfd, sec)->virt_size));
+      }
+
+    aouthdr_in->dsize = dsize;
+    aouthdr_in->tsize = tsize;
+    extra->SizeOfImage = isize;
+  }
+
+  extra->SizeOfHeaders = abfd->sections->filepos;
+  bfd_h_put_16 (abfd, aouthdr_in->magic, (bfd_byte *) aouthdr_out->standard.magic);
+
+#define LINKER_VERSION 256 /* That is, 2.56 */
+
+  /* This piece of magic sets the "linker version" field to
+     LINKER_VERSION.  */
+  bfd_h_put_16 (abfd,
+		LINKER_VERSION / 100 + (LINKER_VERSION % 100) * 256,
+		(bfd_byte *) aouthdr_out->standard.vstamp);
+
+  PUT_AOUTHDR_TSIZE (abfd, aouthdr_in->tsize, (bfd_byte *) aouthdr_out->standard.tsize);
+  PUT_AOUTHDR_DSIZE (abfd, aouthdr_in->dsize, (bfd_byte *) aouthdr_out->standard.dsize);
+  PUT_AOUTHDR_BSIZE (abfd, aouthdr_in->bsize, (bfd_byte *) aouthdr_out->standard.bsize);
+  PUT_AOUTHDR_ENTRY (abfd, aouthdr_in->entry, (bfd_byte *) aouthdr_out->standard.entry);
+  PUT_AOUTHDR_TEXT_START (abfd, aouthdr_in->text_start,
+			  (bfd_byte *) aouthdr_out->standard.text_start);
+
+#ifndef COFF_WITH_pep
+  /* PE32+ does not have data_start member! */
+  PUT_AOUTHDR_DATA_START (abfd, aouthdr_in->data_start,
+			  (bfd_byte *) aouthdr_out->standard.data_start);
+#endif
+
+  PUT_OPTHDR_IMAGE_BASE (abfd, extra->ImageBase,
+			 (bfd_byte *) aouthdr_out->ImageBase);
+  bfd_h_put_32 (abfd, extra->SectionAlignment,
+		(bfd_byte *) aouthdr_out->SectionAlignment);
+  bfd_h_put_32 (abfd, extra->FileAlignment,
+		(bfd_byte *) aouthdr_out->FileAlignment);
+  bfd_h_put_16 (abfd, extra->MajorOperatingSystemVersion,
+		(bfd_byte *) aouthdr_out->MajorOperatingSystemVersion);
+  bfd_h_put_16 (abfd, extra->MinorOperatingSystemVersion,
+		(bfd_byte *) aouthdr_out->MinorOperatingSystemVersion);
+  bfd_h_put_16 (abfd, extra->MajorImageVersion,
+		(bfd_byte *) aouthdr_out->MajorImageVersion);
+  bfd_h_put_16 (abfd, extra->MinorImageVersion,
+		(bfd_byte *) aouthdr_out->MinorImageVersion);
+  bfd_h_put_16 (abfd, extra->MajorSubsystemVersion,
+		(bfd_byte *) aouthdr_out->MajorSubsystemVersion);
+  bfd_h_put_16 (abfd, extra->MinorSubsystemVersion,
+		(bfd_byte *) aouthdr_out->MinorSubsystemVersion);
+  bfd_h_put_32 (abfd, extra->Reserved1,
+		(bfd_byte *) aouthdr_out->Reserved1);
+  bfd_h_put_32 (abfd, extra->SizeOfImage,
+		(bfd_byte *) aouthdr_out->SizeOfImage);
+  bfd_h_put_32 (abfd, extra->SizeOfHeaders,
+		(bfd_byte *) aouthdr_out->SizeOfHeaders);
+  bfd_h_put_32 (abfd, extra->CheckSum,
+		(bfd_byte *) aouthdr_out->CheckSum);
+  bfd_h_put_16 (abfd, extra->Subsystem,
+		(bfd_byte *) aouthdr_out->Subsystem);
+  bfd_h_put_16 (abfd, extra->DllCharacteristics,
+		(bfd_byte *) aouthdr_out->DllCharacteristics);
+  PUT_OPTHDR_SIZE_OF_STACK_RESERVE (abfd, extra->SizeOfStackReserve,
+				    (bfd_byte *) aouthdr_out->SizeOfStackReserve);
+  PUT_OPTHDR_SIZE_OF_STACK_COMMIT (abfd, extra->SizeOfStackCommit,
+				   (bfd_byte *) aouthdr_out->SizeOfStackCommit);
+  PUT_OPTHDR_SIZE_OF_HEAP_RESERVE (abfd, extra->SizeOfHeapReserve,
+				   (bfd_byte *) aouthdr_out->SizeOfHeapReserve);
+  PUT_OPTHDR_SIZE_OF_HEAP_COMMIT (abfd, extra->SizeOfHeapCommit,
+				  (bfd_byte *) aouthdr_out->SizeOfHeapCommit);
+  bfd_h_put_32 (abfd, extra->LoaderFlags,
+		(bfd_byte *) aouthdr_out->LoaderFlags);
+  bfd_h_put_32 (abfd, extra->NumberOfRvaAndSizes,
+		(bfd_byte *) aouthdr_out->NumberOfRvaAndSizes);
+  {
+    int idx;
+    for (idx = 0; idx < 16; idx++)
+      {
+	bfd_h_put_32 (abfd, extra->DataDirectory[idx].VirtualAddress,
+		      (bfd_byte *) aouthdr_out->DataDirectory[idx][0]);
+	bfd_h_put_32 (abfd, extra->DataDirectory[idx].Size,
+		      (bfd_byte *) aouthdr_out->DataDirectory[idx][1]);
+      }
+  }
+
+  return AOUTSZ;
+}
+
+unsigned int
+_bfd_XXi_only_swap_filehdr_out (abfd, in, out)
+     bfd       *abfd;
+     PTR	in;
+     PTR	out;
+{
+  int idx;
+  struct internal_filehdr *filehdr_in = (struct internal_filehdr *) in;
+  struct external_PEI_filehdr *filehdr_out = (struct external_PEI_filehdr *) out;
+
+  if (pe_data (abfd)->has_reloc_section)
+    filehdr_in->f_flags &= ~F_RELFLG;
+
+  if (pe_data (abfd)->dll)
+    filehdr_in->f_flags |= F_DLL;
+
+  filehdr_in->pe.e_magic    = DOSMAGIC;
+  filehdr_in->pe.e_cblp     = 0x90;
+  filehdr_in->pe.e_cp       = 0x3;
+  filehdr_in->pe.e_crlc     = 0x0;
+  filehdr_in->pe.e_cparhdr  = 0x4;
+  filehdr_in->pe.e_minalloc = 0x0;
+  filehdr_in->pe.e_maxalloc = 0xffff;
+  filehdr_in->pe.e_ss       = 0x0;
+  filehdr_in->pe.e_sp       = 0xb8;
+  filehdr_in->pe.e_csum     = 0x0;
+  filehdr_in->pe.e_ip       = 0x0;
+  filehdr_in->pe.e_cs       = 0x0;
+  filehdr_in->pe.e_lfarlc   = 0x40;
+  filehdr_in->pe.e_ovno     = 0x0;
+
+  for (idx = 0; idx < 4; idx++)
+    filehdr_in->pe.e_res[idx] = 0x0;
+
+  filehdr_in->pe.e_oemid   = 0x0;
+  filehdr_in->pe.e_oeminfo = 0x0;
+
+  for (idx = 0; idx < 10; idx++)
+    filehdr_in->pe.e_res2[idx] = 0x0;
+
+  filehdr_in->pe.e_lfanew = 0x80;
+
+  /* This next collection of data are mostly just characters.  It
+     appears to be constant within the headers put on NT exes.  */
+  filehdr_in->pe.dos_message[0]  = 0x0eba1f0e;
+  filehdr_in->pe.dos_message[1]  = 0xcd09b400;
+  filehdr_in->pe.dos_message[2]  = 0x4c01b821;
+  filehdr_in->pe.dos_message[3]  = 0x685421cd;
+  filehdr_in->pe.dos_message[4]  = 0x70207369;
+  filehdr_in->pe.dos_message[5]  = 0x72676f72;
+  filehdr_in->pe.dos_message[6]  = 0x63206d61;
+  filehdr_in->pe.dos_message[7]  = 0x6f6e6e61;
+  filehdr_in->pe.dos_message[8]  = 0x65622074;
+  filehdr_in->pe.dos_message[9]  = 0x6e757220;
+  filehdr_in->pe.dos_message[10] = 0x206e6920;
+  filehdr_in->pe.dos_message[11] = 0x20534f44;
+  filehdr_in->pe.dos_message[12] = 0x65646f6d;
+  filehdr_in->pe.dos_message[13] = 0x0a0d0d2e;
+  filehdr_in->pe.dos_message[14] = 0x24;
+  filehdr_in->pe.dos_message[15] = 0x0;
+  filehdr_in->pe.nt_signature = NT_SIGNATURE;
+
+  bfd_h_put_16 (abfd, filehdr_in->f_magic, (bfd_byte *) filehdr_out->f_magic);
+  bfd_h_put_16 (abfd, filehdr_in->f_nscns, (bfd_byte *) filehdr_out->f_nscns);
+
+  bfd_h_put_32 (abfd, time (0), (bfd_byte *) filehdr_out->f_timdat);
+  PUT_FILEHDR_SYMPTR (abfd, (bfd_vma) filehdr_in->f_symptr,
+		      (bfd_byte *) filehdr_out->f_symptr);
+  bfd_h_put_32 (abfd, filehdr_in->f_nsyms, (bfd_byte *) filehdr_out->f_nsyms);
+  bfd_h_put_16 (abfd, filehdr_in->f_opthdr, (bfd_byte *) filehdr_out->f_opthdr);
+  bfd_h_put_16 (abfd, filehdr_in->f_flags, (bfd_byte *) filehdr_out->f_flags);
+
+  /* put in extra dos header stuff.  This data remains essentially
+     constant, it just has to be tacked on to the beginning of all exes
+     for NT */
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_magic, (bfd_byte *) filehdr_out->e_magic);
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_cblp, (bfd_byte *) filehdr_out->e_cblp);
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_cp, (bfd_byte *) filehdr_out->e_cp);
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_crlc, (bfd_byte *) filehdr_out->e_crlc);
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_cparhdr,
+	       (bfd_byte *) filehdr_out->e_cparhdr);
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_minalloc,
+	       (bfd_byte *) filehdr_out->e_minalloc);
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_maxalloc,
+	       (bfd_byte *) filehdr_out->e_maxalloc);
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_ss, (bfd_byte *) filehdr_out->e_ss);
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_sp, (bfd_byte *) filehdr_out->e_sp);
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_csum, (bfd_byte *) filehdr_out->e_csum);
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_ip, (bfd_byte *) filehdr_out->e_ip);
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_cs, (bfd_byte *) filehdr_out->e_cs);
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_lfarlc, (bfd_byte *) filehdr_out->e_lfarlc);
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_ovno, (bfd_byte *) filehdr_out->e_ovno);
+  {
+    int idx;
+    for (idx = 0; idx < 4; idx++)
+      bfd_h_put_16 (abfd, filehdr_in->pe.e_res[idx],
+		    (bfd_byte *) filehdr_out->e_res[idx]);
+  }
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_oemid, (bfd_byte *) filehdr_out->e_oemid);
+  bfd_h_put_16 (abfd, filehdr_in->pe.e_oeminfo,
+		(bfd_byte *) filehdr_out->e_oeminfo);
+  {
+    int idx;
+    for (idx = 0; idx < 10; idx++)
+      bfd_h_put_16 (abfd, filehdr_in->pe.e_res2[idx],
+		    (bfd_byte *) filehdr_out->e_res2[idx]);
+  }
+  bfd_h_put_32 (abfd, filehdr_in->pe.e_lfanew, (bfd_byte *) filehdr_out->e_lfanew);
+
+  {
+    int idx;
+    for (idx = 0; idx < 16; idx++)
+      bfd_h_put_32 (abfd, filehdr_in->pe.dos_message[idx],
+		    (bfd_byte *) filehdr_out->dos_message[idx]);
+  }
+
+  /* Also put in the NT signature.  */
+  bfd_h_put_32 (abfd, filehdr_in->pe.nt_signature,
+		(bfd_byte *) filehdr_out->nt_signature);
+
+  return FILHSZ;
+}
+
+unsigned int
+_bfd_XX_only_swap_filehdr_out (abfd, in, out)
+     bfd       *abfd;
+     PTR	in;
+     PTR	out;
+{
+  struct internal_filehdr *filehdr_in = (struct internal_filehdr *) in;
+  FILHDR *filehdr_out = (FILHDR *) out;
+
+  bfd_h_put_16 (abfd, filehdr_in->f_magic, (bfd_byte *) filehdr_out->f_magic);
+  bfd_h_put_16 (abfd, filehdr_in->f_nscns, (bfd_byte *) filehdr_out->f_nscns);
+  bfd_h_put_32 (abfd, filehdr_in->f_timdat, (bfd_byte *) filehdr_out->f_timdat);
+  PUT_FILEHDR_SYMPTR (abfd, (bfd_vma) filehdr_in->f_symptr,
+		      (bfd_byte *) filehdr_out->f_symptr);
+  bfd_h_put_32 (abfd, filehdr_in->f_nsyms, (bfd_byte *) filehdr_out->f_nsyms);
+  bfd_h_put_16 (abfd, filehdr_in->f_opthdr, (bfd_byte *) filehdr_out->f_opthdr);
+  bfd_h_put_16 (abfd, filehdr_in->f_flags, (bfd_byte *) filehdr_out->f_flags);
+
+  return FILHSZ;
+}
+
+unsigned int
+_bfd_XXi_swap_scnhdr_out (abfd, in, out)
+     bfd       *abfd;
+     PTR	in;
+     PTR	out;
+{
+  struct internal_scnhdr *scnhdr_int = (struct internal_scnhdr *) in;
+  SCNHDR *scnhdr_ext = (SCNHDR *) out;
+  unsigned int ret = SCNHSZ;
+  bfd_vma ps;
+  bfd_vma ss;
+
+  memcpy (scnhdr_ext->s_name, scnhdr_int->s_name, sizeof (scnhdr_int->s_name));
+
+  PUT_SCNHDR_VADDR (abfd,
+		    ((scnhdr_int->s_vaddr
+		      - pe_data (abfd)->pe_opthdr.ImageBase)
+		     & 0xffffffff),
+		    (bfd_byte *) scnhdr_ext->s_vaddr);
+
+  /* NT wants the size data to be rounded up to the next
+     NT_FILE_ALIGNMENT, but zero if it has no content (as in .bss,
+     sometimes).  */
+
+  if ((scnhdr_int->s_flags & IMAGE_SCN_CNT_UNINITIALIZED_DATA) != 0)
+    {
+      ps = scnhdr_int->s_size;
+      ss = 0;
+    }
+  else
+    {
+      ps = scnhdr_int->s_paddr;
+      ss = scnhdr_int->s_size;
+    }
+
+  PUT_SCNHDR_SIZE (abfd, ss,
+		   (bfd_byte *) scnhdr_ext->s_size);
+
+  /* s_paddr in PE is really the virtual size.  */
+  PUT_SCNHDR_PADDR (abfd, ps, (bfd_byte *) scnhdr_ext->s_paddr);
+
+  PUT_SCNHDR_SCNPTR (abfd, scnhdr_int->s_scnptr,
+		     (bfd_byte *) scnhdr_ext->s_scnptr);
+  PUT_SCNHDR_RELPTR (abfd, scnhdr_int->s_relptr,
+		     (bfd_byte *) scnhdr_ext->s_relptr);
+  PUT_SCNHDR_LNNOPTR (abfd, scnhdr_int->s_lnnoptr,
+		      (bfd_byte *) scnhdr_ext->s_lnnoptr);
+
+  /* Extra flags must be set when dealing with NT.  All sections should also
+     have the IMAGE_SCN_MEM_READ (0x40000000) flag set.  In addition, the
+     .text section must have IMAGE_SCN_MEM_EXECUTE (0x20000000) and the data
+     sections (.idata, .data, .bss, .CRT) must have IMAGE_SCN_MEM_WRITE set
+     (this is especially important when dealing with the .idata section since
+     the addresses for routines from .dlls must be overwritten).  If .reloc
+     section data is ever generated, we must add IMAGE_SCN_MEM_DISCARDABLE
+     (0x02000000).  Also, the resource data should also be read and
+     writable.  */
+
+  /* FIXME: alignment is also encoded in this field, at least on ppc (krk) */
+  /* FIXME: even worse, I don't see how to get the original alignment field*/
+  /*        back...                                                        */
+
+  {
+    int flags = scnhdr_int->s_flags;
+    bfd_h_put_32 (abfd, flags, (bfd_byte *) scnhdr_ext->s_flags);
+  }
+
+  if (coff_data (abfd)->link_info
+      && ! coff_data (abfd)->link_info->relocateable

