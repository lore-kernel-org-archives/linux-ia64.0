From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 11 Aug 2000 02:50:33 +0000
Subject: Re: [Linux-ia64] 2.4.0-test5-pre4 patch for IA64 make
Message-Id: <marc-linux-ia64-105590678205316@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205229@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205229@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	When compiling with -mconstant-gp, this version of gcc does not set
	EF_IA_64_CONS_GP in the ELF e_flags field (bit 0x00000040).  This makes
	it impossible for insmod to verify if a module was compiled with
	-mconstant-gp or not.

I believe this patch does what you need.  This was written for the curernt
development sources.  I haven't tried patching it into the February release.

There is an unfortunately gas/ias incompatibility here.  Intel as does not
appear to provide any directives for setting the elf e_flags field, only
command line options.  However, the command line options used conflict with
existing gas options, so I can't use them.  So I used the same options that gcc
is already using.

bfd/
2000-08-10  Jim Wilson  <wilson@cygnus.com>

	* elf64-ia64.c (elf64_ia64_merge_private_bfd_data): Handle
	EF_IA_64_REDUCEDFP, EF_IA_64_CONS_GP, and EF_IA_64_NOFUNCDESC_CONS_GP.
	(elf64_ia64_print_private_bfd_data): Likewise.  Also handle
	EF_IA_64_ABSOLUTE.

gas/
2000-08-10  Jim Wilson  <wilson@cygnus.com>

	* config/tc-ia64.c (md_longopts): Add -mconstant-gp and -mauto-pic.
	(md_parse_option):  Add OPTION_MCONSTANT_GP and OPTION_MAUTO_PIC.
	(md_begin): Change assignment to md.flag to OR in the new bit.

gcc/
2000-08-10  Jim Wilson  <wilson@cygnus.com>

	* config/ia64/ia64.h (ASM_SPEC): Pass -mconstant-gp and -mauto-pic
	to GNU as.  For Intel as, pass -M const_gp and -M no_plabel.
	* config/ia64/linux.h (ASM_SPEC): Pass -mconstant-gp and -mauto-pic
	to GNU as.

include/elf/
2000-08-10  Jim Wilson  <wilson@cygnus.com>

	* elf/ia64.h (EF_IA_64_REDUCEDFP, EF_IA_64_CONS_GP,
	EF_IA_64_NOFUNCDESC_CONS_GP, EF_IA_64_ABSOLUTE): Define.

Index: bfd/elf64-ia64.c
=================================RCS file: /cvs/cvsfiles/devo/bfd/elf64-ia64.c,v
retrieving revision 1.31
diff -p -r1.31 elf64-ia64.c
*** elf64-ia64.c	2000/07/29 20:23:15	1.31
--- elf64-ia64.c	2000/08/11 02:16:26
*************** elf64_ia64_merge_private_bfd_data (ibfd,
*** 4202,4207 ****
--- 4202,4211 ----
    if (in_flags = out_flags)
      return true;
  
+   /* Output has EF_IA_64_REDUCEDFP set only if all inputs have it set.  */
+   if (!(in_flags & EF_IA_64_REDUCEDFP) && (out_flags & EF_IA_64_REDUCEDFP))
+     elf_elfheader (obfd)->e_flags &= ~EF_IA_64_REDUCEDFP;
+ 
    if ((in_flags & EF_IA_64_TRAPNIL) != (out_flags & EF_IA_64_TRAPNIL))
      {
        (*_bfd_error_handler)
*************** elf64_ia64_merge_private_bfd_data (ibfd,
*** 4229,4234 ****
--- 4233,4257 ----
        bfd_set_error (bfd_error_bad_value);
        ok = false;
      }
+   if ((in_flags & EF_IA_64_CONS_GP) != (out_flags & EF_IA_64_CONS_GP))
+     {
+       (*_bfd_error_handler)
+ 	(_("%s: linking constant-gp files with non-constant-gp files"),
+ 	 bfd_get_filename (ibfd));
+ 
+       bfd_set_error (bfd_error_bad_value);
+       ok = false;
+     }
+   if ((in_flags & EF_IA_64_NOFUNCDESC_CONS_GP)
+       != (out_flags & EF_IA_64_NOFUNCDESC_CONS_GP))
+     {
+       (*_bfd_error_handler)
+ 	(_("%s: linking auto-pic files with non-auto-pic files"),
+ 	 bfd_get_filename (ibfd));
+ 
+       bfd_set_error (bfd_error_bad_value);
+       ok = false;
+     }
  
    return ok;
  }
*************** elf64_ia64_print_private_bfd_data (abfd,
*** 4243,4253 ****
  
    BFD_ASSERT (abfd != NULL && ptr != NULL);
  
!   fprintf (file, "private flags = %s%s%s%s\n",
  	   (flags & EF_IA_64_TRAPNIL) ? "TRAPNIL, " : "",
  	   (flags & EF_IA_64_EXT) ? "EXT, " : "",
  	   (flags & EF_IA_64_BE) ? "BE, " : "LE, ",
  	   (flags & EF_IA_64_ABI64) ? "ABI64" : "ABI32");
    _bfd_elf_print_private_bfd_data (abfd, ptr);
    return true;
  }
--- 4266,4281 ----
  
    BFD_ASSERT (abfd != NULL && ptr != NULL);
  
!   fprintf (file, "private flags = %s%s%s%s%s%s%s%s\n",
  	   (flags & EF_IA_64_TRAPNIL) ? "TRAPNIL, " : "",
  	   (flags & EF_IA_64_EXT) ? "EXT, " : "",
  	   (flags & EF_IA_64_BE) ? "BE, " : "LE, ",
+ 	   (flags & EF_IA_64_REDUCEDFP) ? "REDUCEDFP, " : "",
+ 	   (flags & EF_IA_64_CONS_GP) ? "CONS_GP, " : "",
+ 	   (flags & EF_IA_64_NOFUNCDESC_CONS_GP) ? "NOFUNCDESC_CONS_GP, " : "",
+ 	   (flags & EF_IA_64_ABSOLUTE) ? "ABSOLUTE, " : "",
  	   (flags & EF_IA_64_ABI64) ? "ABI64" : "ABI32");
+   
    _bfd_elf_print_private_bfd_data (abfd, ptr);
    return true;
  }
Index: gas/config/tc-ia64.c
=================================RCS file: /cvs/cvsfiles/devo/gas/config/tc-ia64.c,v
retrieving revision 1.59
diff -p -r1.59 tc-ia64.c
*** tc-ia64.c	2000/08/02 21:27:11	1.59
--- tc-ia64.c	2000/08/11 02:16:31
*************** const char *md_shortopts = "M:N:x::";
*** 160,166 ****
  
  struct option md_longopts[]     {
!     { NULL, no_argument, NULL, 0}
    };
  
  size_t md_longopts_size = sizeof (md_longopts);
--- 160,169 ----
  
  struct option md_longopts[]     {
! #define OPTION_MCONSTANT_GP (OPTION_MD_BASE + 1)
!     {"mconstant-gp", no_argument, NULL, OPTION_MCONSTANT_GP},
! #define OPTION_MAUTO_PIC (OPTION_MD_BASE + 2)
!     {"mauto-pic", no_argument, NULL, OPTION_MAUTO_PIC}
    };
  
  size_t md_longopts_size = sizeof (md_longopts);
*************** md_parse_option (c, arg)
*** 5521,5529 ****
       int c;
       char *arg;
  {
-   /* Switches from the Intel assembler.  */
    switch (c)
      {
      case 'M':
        if (strcmp (arg, "ilp64") = 0
  	  || strcmp (arg, "lp64") = 0
--- 5524,5532 ----
       int c;
       char *arg;
  {
    switch (c)
      {
+     /* Switches from the Intel assembler.  */
      case 'M':
        if (strcmp (arg, "ilp64") = 0
  	  || strcmp (arg, "lp64") = 0
*************** md_parse_option (c, arg)
*** 5616,5621 ****
--- 5619,5633 ----
        /* nops		Print nops statistics.  */
        break;
  
+     /* GNU specific switches for gcc.  */
+     case OPTION_MCONSTANT_GP:
+       md.flags |= EF_IA_64_CONS_GP;
+       break;
+ 
+     case OPTION_MAUTO_PIC:
+       md.flags |= EF_IA_64_NOFUNCDESC_CONS_GP;
+       break;
+ 
      default:
        return 0;
      }
*************** md_begin ()
*** 5867,5873 ****
      }
  
    /* Default to 64-bit mode.  */
!   md.flags = EF_IA_64_ABI64;
  
    md.mem_offset.hint = 0;
    md.path = 0;
--- 5879,5886 ----
      }
  
    /* Default to 64-bit mode.  */
!   /* ??? This overrides the -M options, but they aren't working anyways.  */
!   md.flags |= EF_IA_64_ABI64;
  
    md.mem_offset.hint = 0;
    md.path = 0;
Index: gcc/config/ia64/ia64.h
=================================RCS file: /cvs/cvsfiles/devo/gcc/config/ia64/ia64.h,v
retrieving revision 1.77
diff -p -r1.77 ia64.h
*** ia64.h	2000/07/31 17:37:22	1.77
--- ia64.h	2000/08/11 02:40:40
*************** extern const char *ia64_fixed_range_stri
*** 238,247 ****
  
  #if ((TARGET_CPU_DEFAULT | TARGET_DEFAULT) & MASK_GNU_AS) != 0
  /* GNU AS.  */
! #define ASM_SPEC "%{mno-gnu-as:-N so}%{!mno-gnu-as: -x}"
  #else
  /* Intel ias.  */
! #define ASM_SPEC "%{!mgnu-as:-N so}%{mgnu-as: -x}"
  #endif
  
  /* A C string constant that tells the GNU CC driver program options to pass to
--- 238,250 ----
  
  #if ((TARGET_CPU_DEFAULT | TARGET_DEFAULT) & MASK_GNU_AS) != 0
  /* GNU AS.  */
! #define ASM_SPEC \
!   "%{mno-gnu-as:-N so} %{!mno-gnu-as:-x} %{mconstant-gp} %{mauto-pic}"
  #else
  /* Intel ias.  */
! #define ASM_SPEC \
!   "%{!mgnu-as:-N so} %{mgnu-as:-x} %{mconstant-gp:-M const_gp}\
!    %{mauto-pic:-M no_plabel}"
  #endif
  
  /* A C string constant that tells the GNU CC driver program options to pass to
Index: gcc/config/ia64/linux.h
=================================RCS file: /cvs/cvsfiles/devo/gcc/config/ia64/linux.h,v
retrieving revision 1.14
diff -p -r1.14 linux.h
*** linux.h	2000/06/29 19:03:26	1.14
--- linux.h	2000/08/11 02:16:36
***************
*** 10,16 ****
  
  /* ??? ia64 gas doesn't accept standard svr4 assembler options?  */
  #undef ASM_SPEC
! #define ASM_SPEC "-x"
  
  /* Define this for shared library support because it isn't in the main
     linux.h file.  */
--- 10,16 ----
  
  /* ??? ia64 gas doesn't accept standard svr4 assembler options?  */
  #undef ASM_SPEC
! #define ASM_SPEC "-x %{mconstant-gp} %{mauto-pic}"
  
  /* Define this for shared library support because it isn't in the main
     linux.h file.  */
Index: include/elf/ia64.h
=================================RCS file: /cvs/cvsfiles/devo/include/elf/ia64.h,v
retrieving revision 1.8
diff -p -r1.8 ia64.h
*** ia64.h	2000/07/29 20:21:17	1.8
--- ia64.h	2000/08/11 02:16:49
*************** Foundation, Inc., 59 Temple Place - Suit
*** 25,31 ****
  /* Bits in the e_flags field of the Elf64_Ehdr:  */
  
  #define EF_IA_64_MASKOS	 0x0000000f	/* os-specific flags */
- #define EF_IA_64_ABI64	 (1 << 4)	/* 64-bit ABI */
  #define EF_IA_64_ARCH	 0xff000000	/* arch. version mask */
  
  /* ??? These four definitions are not part of the SVR4 ABI.
--- 25,30 ----
*************** Foundation, Inc., 59 Temple Place - Suit
*** 35,40 ****
--- 34,47 ----
  #define EF_IA_64_EXT	 (1 << 2)	/* program uses arch. extensions */
  #define EF_IA_64_BE	 (1 << 3)	/* PSR BE bit set (big-endian) */
  #define EFA_IA_64_EAS2_3 0x23000000	/* ia64 EAS 2.3 */
+ 
+ #define EF_IA_64_ABI64		    (1 << 4) /* 64-bit ABI */
+ /* Not used yet.  */
+ #define EF_IA_64_REDUCEDFP	    (1 << 5) /* Only FP6-FP11 used.  */
+ #define EF_IA_64_CONS_GP	    (1 << 6) /* gp as program wide constant. */
+ #define EF_IA_64_NOFUNCDESC_CONS_GP (1 << 7) /* And no function descriptors. */
+ /* Not used yet.  */
+ #define EF_IA_64_ABSOLUTE	    (1 << 8) /* Load at absolute addresses.  */
  
  #define ELF_STRING_ia64_archext		".IA_64.archext"
  #define ELF_STRING_ia64_pltoff		".IA_64.pltoff"

