From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 26 Apr 2000 18:58:27 +0000
Subject: Re: [Linux-ia64] ld failure
Message-Id: <marc-linux-ia64-105590678205054@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205047@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205047@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is an optional patch available for the current stable toolchain that
fixes this.  There are a few details to work out.
1) It uses the linker relaxation support, which isn't the default.  So for
   the moment the user needs to manually specify -Wl,-relax on the gcc command
   line.
2) It uses the brl instruction which the Itanium does not implement.  The
   kernel needs to emulate the instruction.  I know that people are working on
   this kernel support, but I don't know if it is available yet.  So you will
   be able to link the program, but you may not be able to run it.
3) The ABI does not define relocations for brl yet, so we invented our own.
   These will have to change when standard relocations are specified, which
   may result in a user visble ABI change.

These problems should hopefully all be resolved by the time of the next
toolchain release, which is tentatively scheduled for late June.

Looking at this, I see that some rearrangement of code in our startup files
might help delay the point at which a program becomes too big.  I'll make a
note to myself to look into that.

bfd/
	* elf64-ia64.c (ia64_howto_table): Add PCREL60L.
	(elf64_ia64_reloc_type_lookup): Likewise.
	(elf64_ia64_relax_section): New.
	(elf64_ia64_check_relocs): Handle PCREL60L.
	(elf64_ia64_install_value): Likewise.
	(elf64_ia64_relocate_section): Likewise.
	(bfd_elf64_bfd_relax_section): New.
	* reloc.c (BFD_RELOC_IA64_PCREL60L): New.

include/elf/
	* ia64.h (R_IA64_PCREL60L): Likewise.

gas/
	* config/tc-ia64.c (operand_match):  Handle IA64_OPND_TGT64.
	(build_insn): Likewise.
	(fix_insn): Handle all three 64-bit relocation types.

opcodes/
	* ia64-dis.c (print_insn_ia64): Handle IA64_OPND_TGT64.
	Get return value currect for X type insns.


Index: bfd/bfd-in2.h
=================================RCS file: /cvs/cvsfiles/devo/bfd/bfd-in2.h,v
retrieving revision 1.361.4.2
diff -c -p -d -r1.361.4.2 bfd-in2.h
*** bfd/bfd-in2.h	2000/03/24 20:37:08	1.361.4.2
--- bfd/bfd-in2.h	2000/04/11 08:38:13
*************** this offset in the reloc's section offse
*** 2323,2328 ****
--- 2323,2329 ----
    BFD_RELOC_IA64_PCREL32LSB,
    BFD_RELOC_IA64_PCREL64MSB,
    BFD_RELOC_IA64_PCREL64LSB,
+   BFD_RELOC_IA64_PCREL60L,
    BFD_RELOC_IA64_LTOFF_FPTR22,
    BFD_RELOC_IA64_LTOFF_FPTR64I,
    BFD_RELOC_IA64_LTOFF_FPTR64MSB,
Index: bfd/elf64-ia64.c
=================================RCS file: /cvs/cvsfiles/devo/bfd/elf64-ia64.c,v
retrieving revision 1.22.4.6
diff -c -p -d -r1.22.4.6 elf64-ia64.c
*** bfd/elf64-ia64.c	2000/03/31 04:04:02	1.22.4.6
--- bfd/elf64-ia64.c	2000/04/11 08:38:13
***************
*** 1,5 ****
  /* IA-64 support for 64-bit ELF
!    Copyright 1998, 1999 Free Software Foundation, Inc.
     Contributed by David Mosberger-Tang <davidm@hpl.hp.com>
  
  This file is part of BFD, the Binary File Descriptor library.
--- 1,5 ----
  /* IA-64 support for 64-bit ELF
!    Copyright 1998, 1999, 2000 Free Software Foundation, Inc.
     Contributed by David Mosberger-Tang <davidm@hpl.hp.com>
  
  This file is part of BFD, the Binary File Descriptor library.
*************** Foundation, Inc., 59 Temple Place - Suit
*** 25,30 ****
--- 25,31 ----
  #include "opcode/ia64.h"
  #include "elf/ia64.h"
  
+ 
  /*
   * THE RULES for all the stuff the linker creates --
   *
*************** static reloc_howto_type *elf64_ia64_relo
*** 154,159 ****
--- 155,163 ----
    PARAMS ((bfd *abfd, bfd_reloc_code_real_type bfd_code));
  static void elf64_ia64_info_to_howto
    PARAMS ((bfd *abfd, arelent *bfd_reloc, Elf64_Internal_Rela *elf_reloc));
+ static boolean elf64_ia64_relax_section
+   PARAMS((bfd *abfd, asection *sec, struct bfd_link_info *link_info,
+ 	  boolean *again));
  static boolean elf64_ia64_section_from_shdr
    PARAMS ((bfd *, Elf64_Internal_Shdr *, char *));
  static boolean elf64_ia64_fake_sections
*************** static reloc_howto_type ia64_howto_table
*** 381,386 ****
--- 385,392 ----
      IA64_HOWTO (R_IA64_TPREL64MSB,  "TPREL64MSB",  8, false, false),
      IA64_HOWTO (R_IA64_TPREL64LSB,  "TPREL64LSB",  8, false, false),
      IA64_HOWTO (R_IA64_LTOFF_TP22,  "LTOFF_TP22",  4, false, false),
+ 
+     IA64_HOWTO (R_IA64_PCREL60L,    "PCREL60L",	   0, true, true),
    };
  
  static unsigned char elf_code_to_howto_index[R_IA64_MAX_RELOC_CODE + 1];
*************** elf64_ia64_reloc_type_lookup (abfd, bfd_
*** 457,462 ****
--- 463,469 ----
      case BFD_RELOC_IA64_PCREL32LSB:	rtype = R_IA64_PCREL32LSB; break;
      case BFD_RELOC_IA64_PCREL64MSB:	rtype = R_IA64_PCREL64MSB; break;
      case BFD_RELOC_IA64_PCREL64LSB:	rtype = R_IA64_PCREL64LSB; break;
+     case BFD_RELOC_IA64_PCREL60L:	rtype = R_IA64_PCREL60L; break;
  
      case BFD_RELOC_IA64_LTOFF_FPTR22:	rtype = R_IA64_LTOFF_FPTR22; break;
      case BFD_RELOC_IA64_LTOFF_FPTR64I:	rtype = R_IA64_LTOFF_FPTR64I; break;
*************** static const bfd_byte plt_full_entry[PLT
*** 550,555 ****
--- 557,872 ----
  
  #define ELF_DYNAMIC_INTERPRETER "/usr/lib/ld.so.1"
  
+ /* These functions do relaxation for IA-64 ELF.
+ 
+    This is primarily to support branches to targets out of range;
+    relaxation of R_IA64_LTOFF22X and R_IA64_LDXMOV not yet supported.  */
+ 
+ static boolean
+ elf64_ia64_relax_section (abfd, sec, link_info, again)
+      bfd *abfd;
+      asection *sec;
+      struct bfd_link_info *link_info;
+      boolean *again;
+ {
+   struct one_fixup
+     {
+       struct one_fixup *next;
+       asection *tsec;
+       bfd_vma toff;
+       bfd_vma trampoff;
+     };
+ 
+   Elf_Internal_Shdr *symtab_hdr;
+   Elf_Internal_Rela *internal_relocs;
+   Elf_Internal_Rela *free_relocs;
+   Elf_Internal_Rela *irel, *irelend;
+   bfd_byte *contents;
+   bfd_byte *free_contents;
+   Elf64_External_Sym *extsyms;
+   Elf64_External_Sym *free_extsyms;
+   struct elf64_ia64_link_hash_table *ia64_info;
+   struct one_fixup *fixups = NULL;
+   boolean changed_contents = false;
+   boolean changed_relocs = false;
+ 
+   /* Assume we're not going to change any sizes, and we we'll only
+      need one pass.  */
+   *again = false;
+ 
+   /* Nothing to do if there are no relocations.  */
+   if ((sec->flags & SEC_RELOC) = 0
+       || sec->reloc_count = 0)
+     return true;
+ 
+   /* If this is the first time we have been called for this section,
+      initialize the cooked size.  */
+   if (sec->_cooked_size = 0)
+     sec->_cooked_size = sec->_raw_size;
+ 
+   symtab_hdr = &elf_tdata (abfd)->symtab_hdr;
+ 
+   /* Load the relocations for this section.  */
+   internal_relocs = (_bfd_elf64_link_read_relocs
+ 		     (abfd, sec, (PTR) NULL, (Elf_Internal_Rela *) NULL,
+ 		      link_info->keep_memory));
+   if (internal_relocs = NULL)
+     goto error_return;
+   free_relocs = NULL;
+   if (! link_info->keep_memory)
+     free_relocs = internal_relocs;
+ 
+   ia64_info = elf64_ia64_hash_table (link_info);
+   irelend = internal_relocs + sec->reloc_count;
+ 
+   for (irel = internal_relocs; irel < irelend; irel++)
+     if (ELF64_R_TYPE (irel->r_info) = (int) R_IA64_PCREL21B)
+       break;
+ 
+   /* No branch-type relocations.  */
+   if (irel = irelend)
+     {
+       if (free_relocs != NULL)
+ 	free (free_relocs);
+       return true;
+     }
+ 
+   /* Get the section contents.  */
+   free_contents = NULL;
+   if (elf_section_data (sec)->this_hdr.contents != NULL)
+     contents = elf_section_data (sec)->this_hdr.contents;
+   else
+     {
+       contents = (bfd_byte *) bfd_malloc (sec->_raw_size);
+       if (contents = NULL)
+ 	goto error_return;
+       free_contents = contents;
+ 
+       if (! bfd_get_section_contents (abfd, sec, contents,
+ 				      (file_ptr) 0, sec->_raw_size))
+ 	goto error_return;
+     }
+ 
+   /* Read this BFD's symbols.  */
+   free_extsyms = NULL;
+   if (symtab_hdr->contents != NULL)
+     extsyms = (Elf64_External_Sym *) symtab_hdr->contents;
+   else
+     {
+       extsyms = (Elf64_External_Sym *) bfd_malloc (symtab_hdr->sh_size);
+       if (extsyms = NULL)
+ 	goto error_return;
+       free_extsyms = extsyms;
+       if (bfd_seek (abfd, symtab_hdr->sh_offset, SEEK_SET) != 0
+ 	  || (bfd_read (extsyms, 1, symtab_hdr->sh_size, abfd)
+ 	      != symtab_hdr->sh_size))
+ 	goto error_return;
+     }
+ 
+   for (; irel < irelend; irel++)
+     {
+       bfd_vma symaddr, reladdr, trampoff, toff, roff;
+       Elf_Internal_Sym isym;
+       asection *tsec;
+       struct one_fixup *f;
+ 
+       if (ELF64_R_TYPE (irel->r_info) != (int) R_IA64_PCREL21B)
+ 	continue;
+ 
+       /* Get the value of the symbol referred to by the reloc.  */
+       if (ELF64_R_SYM (irel->r_info) < symtab_hdr->sh_info)
+ 	{
+ 	  /* A local symbol.  */
+ 	  bfd_elf64_swap_symbol_in (abfd,
+ 				    extsyms + ELF64_R_SYM (irel->r_info),
+ 				    &isym);
+ 	  if (isym.st_shndx = SHN_UNDEF)
+ 	    continue;	/* We can't do anthing with undefined symbols.  */
+ 	  else if (isym.st_shndx = SHN_ABS)
+ 	    tsec = bfd_abs_section_ptr;
+ 	  else if (isym.st_shndx = SHN_COMMON)
+ 	    tsec = bfd_com_section_ptr;
+ 	  else if (isym.st_shndx > 0 && isym.st_shndx < SHN_LORESERVE)
+ 	    tsec = bfd_section_from_elf_index (abfd, isym.st_shndx);
+ 	  else 
+ 	    continue;	/* who knows. */
+ 
+ 	  toff = isym.st_value;
+ 	}
+       else
+ 	{
+ 	  unsigned long indx;
+ 	  struct elf_link_hash_entry *h;
+           struct elf64_ia64_dyn_sym_info *dyn_i;
+ 
+ 	  indx = ELF64_R_SYM (irel->r_info) - symtab_hdr->sh_info;
+ 	  h = elf_sym_hashes (abfd)[indx];
+ 	  BFD_ASSERT (h != NULL);
+ 
+ 	  while (h->root.type = bfd_link_hash_indirect
+ 		 || h->root.type = bfd_link_hash_warning)
+ 	    h = (struct elf_link_hash_entry *) h->root.u.i.link;
+ 
+ 	  dyn_i = get_dyn_sym_info (ia64_info, h, abfd, irel, false);
+ 
+ 	  /* For branches to dynamic symbols, we're interested instead
+ 	     in a branch to the PLT entry.  */
+ 	  if (dyn_i && dyn_i->want_plt2)
+ 	    {
+ 	      tsec = ia64_info->plt_sec;
+ 	      toff = dyn_i->plt2_offset;
+ 	    }
+ 	  else
+ 	    {
+ 	      /* We can't do anthing with undefined symbols.  */
+ 	      if (h->root.type = bfd_link_hash_undefined
+ 		  || h->root.type = bfd_link_hash_undefweak)
+ 		continue;
+ 
+ 	      tsec = h->root.u.def.section;
+ 	      toff = h->root.u.def.value;
+ 	    }
+ 	}
+ 
+       symaddr = (tsec->output_section->vma
+ 		 + tsec->output_offset
+ 		 + toff
+ 		 + irel->r_addend);
+ 
+       roff = irel->r_offset;
+       reladdr = (sec->output_section->vma
+ 		 + sec->output_offset
+ 		 + roff) & -4;
+ 
+       /* If the branch is in range, no need to do anything.  */
+       if ((bfd_signed_vma) (symaddr - reladdr) >= -0x1000000
+ 	  && (bfd_signed_vma) (symaddr - reladdr) <= 0x0FFFFF0)
+ 	continue;
+ 
+       /* If the branch and target are in the same section, you've
+ 	 got one honking big section and we can't help you.  You'll
+ 	 get an error message later.  */
+       if (tsec = sec)
+ 	continue;
+ 
+       /* Look for an existing fixup to this address.  */
+       for (f = fixups; f ; f = f->next)
+ 	if (f->tsec = tsec && f->toff = toff)
+ 	  break;
+ 
+       if (f = NULL)
+ 	{
+ 	  /* Two alternatives: If it's a branch to a PLT entry, we can
+ 	     make a copy of the FULL_PLT entry.  Otherwise, we'll have
+ 	     to use a `brl' insn to get where we're going.  */
+ 
+ 	  int size = (tsec = ia64_info->plt_sec ? PLT_FULL_ENTRY_SIZE : 16);
+ 
+ 	  /* Resize the current section to make room for the new branch.  */
+ 	  trampoff = (sec->_cooked_size + 15) & -16;
+ 	  contents = (bfd_byte *) bfd_realloc (contents, trampoff + size);
+ 	  if (contents = NULL)
+ 	    goto error_return;
+ 	  sec->_cooked_size = trampoff + size;
+ 
+ 	  if (size = PLT_FULL_ENTRY_SIZE)
+ 	    {
+ 	      memcpy (contents + trampoff, plt_full_entry, size);
+ 
+ 	      /* Hijack the old relocation for use as the PLTOFF reloc.  */
+ 	      irel->r_info = ELF64_R_INFO (ELF64_R_SYM (irel->r_info),
+ 					   R_IA64_PLTOFF22);
+ 	      irel->r_offset = trampoff;
+ 	    }
+ 	  else
+ 	    {
+ 	      /* Install `{ .mlx; nop.m 0; brl.sptk.few target ;; }'.  */
+ 	      /* ??? Could copy the prefetch bit from the source, as well as
+ 		 install .few instead of .many in the source.  */
+ 	      bfd_put_64 (abfd, 0x0000000100000005LL, contents + trampoff);
+ 	      bfd_put_64 (abfd, 0xc000000000000000LL, contents + trampoff + 8);
+ 
+ 	      /* Hijack the old relocation for use by the trampoline.  */
+ 	      irel->r_info = ELF64_R_INFO (ELF64_R_SYM (irel->r_info),
+ 					   R_IA64_PCREL60L);
+ 	      irel->r_offset = trampoff;
+ 	    }
+ 
+ 	  /* Record the fixup so we don't do it again this section.  */
+ 	  f = (struct one_fixup *) bfd_malloc (sizeof (*f));
+ 	  f->next = fixups;
+ 	  f->tsec = tsec;
+ 	  f->toff = toff;
+ 	  f->trampoff = trampoff;
+ 	  fixups = f;
+ 	}
+       else
+ 	{
+ 	  /* Nop out the reloc, since we're finalizing things here.  */
+ 	  irel->r_info = ELF64_R_INFO (0, R_IA64_NONE);
+ 	}
+ 
+       /* Fix up the existing branch to hit the trampoline.  Hope like
+ 	 hell this doesn't overflow too.  */
+       if (elf64_ia64_install_value (abfd, contents + roff,
+ 				    f->trampoff - (roff & -4),
+ 				    R_IA64_PCREL21B) != bfd_reloc_ok)
+ 	goto error_return;
+ 
+       changed_contents = true;
+       changed_relocs = true;
+     }
+ 
+   /* Clean up and go home.  */
+   while (fixups)
+     {
+       struct one_fixup *f = fixups;
+       fixups = fixups->next;
+       free (f);
+     }
+ 
+   if (changed_relocs)
+     elf_section_data (sec)->relocs = internal_relocs;
+   else if (free_relocs != NULL)
+     free (free_relocs);
+ 
+   if (changed_contents)
+     elf_section_data (sec)->this_hdr.contents = contents;
+   else if (free_contents != NULL)
+     {
+       if (! link_info->keep_memory)
+ 	free (free_contents);
+       else
+ 	{
+ 	  /* Cache the section contents for elf_link_input_bfd.  */
+ 	  elf_section_data (sec)->this_hdr.contents = contents;
+ 	}
+     }
+ 
+   if (free_extsyms != NULL)
+     {
+       if (! link_info->keep_memory)
+ 	free (free_extsyms);
+       else
+ 	{
+ 	  /* Cache the symbols for elf_link_input_bfd.  */
+ 	  symtab_hdr->contents = extsyms;
+ 	}
+     }
+ 
+   *again = changed_contents || changed_relocs;
+   return true;
+ 
+  error_return:
+   if (free_relocs != NULL)
+     free (free_relocs);
+   if (free_contents != NULL)
+     free (free_contents);
+   if (free_extsyms != NULL)
+     free (free_extsyms);
+   return false;
+ }
+ 
  /* Handle an IA-64 specific section when reading an object file.  This
     is called when elfcode.h finds a section with an unknown type.  */
  
*************** elf64_ia64_check_relocs (abfd, info, sec
*** 1473,1478 ****
--- 1790,1796 ----
  	  break;
  
  	case R_IA64_PCREL21B:
+         case R_IA64_PCREL60L:
  	  /* Depending on where this symbol is defined, we may or may not
  	     need a full plt entry.  Only skip if we know we'll not need
  	     the entry -- static or symbolic, and the symbol definition
*************** elf64_ia64_install_value (abfd, hit_addr
*** 2193,2198 ****
--- 2511,2517 ----
      case R_IA64_PCREL21F:	opnd = IA64_OPND_TGT25; break;
      case R_IA64_PCREL21M:	opnd = IA64_OPND_TGT25b; break;
      case R_IA64_PCREL21B:	opnd = IA64_OPND_TGT25c; break;
+     case R_IA64_PCREL60L:	opnd = IA64_OPND_TGT64; break;
  
      case R_IA64_IMM22:
      case R_IA64_GPREL22:
*************** elf64_ia64_install_value (abfd, hit_addr
*** 2313,2318 ****
--- 2632,2662 ----
        bfd_put_64 (abfd, t1, hit_addr + 8);
        break;
  
+     case IA64_OPND_TGT64:
+       hit_addr -= (long) hit_addr & 0x3;
+       t0 = bfd_get_64 (abfd, hit_addr);
+       t1 = bfd_get_64 (abfd, hit_addr + 8);
+ 
+       /* tmpl/s: bits  0.. 5 in t0
+ 	 slot 0: bits  5..45 in t0
+ 	 slot 1: bits 46..63 in t0, bits 0..22 in t1
+ 	 slot 2: bits 23..63 in t1 */
+ 
+       /* First, clear the bits that form the 64 bit constant.  */
+       t0 &= ~(0x3ffffLL << 46);
+       t1 &= ~(0x7fffffLL
+ 	      | ((1LL << 36 | 0xfffffLL << 13) << 23));
+ 
+       val >>= 4;
+       t0 |= ((val >> 20) & 0xffffLL) << 2 << 46;	/* 16 lsbs of imm39 */
+       t1 |= ((val >> 36) & 0x7fffffLL) << 0;		/* 23 msbs of imm39 */
+       t1 |= ((((val >> 0) & 0xfffffLL) << 13)		/* imm20b */
+ 	      | (((val >> 59) & 0x1LL) << 36)) << 23;	/* i */
+ 
+       bfd_put_64 (abfd, t0, hit_addr);
+       bfd_put_64 (abfd, t1, hit_addr + 8);
+       break;
+ 
      default:
        switch ((long) hit_addr & 0x3)
  	{
*************** elf64_ia64_relocate_section (output_bfd,
*** 3117,3122 ****
--- 3461,3467 ----
  	  goto finish_pcrel;
  
  	case R_IA64_PCREL21B:
+ 	case R_IA64_PCREL60L:
  	  /* We should have created a PLT entry for any dynamic symbol.  */
  	  /* ??? How to handle out of range branches, which are supposed
  	     to be fixed up by a conforming linker.  */
*************** elf64_ia64_print_private_bfd_data (abfd,
*** 3654,3659 ****
--- 3999,4006 ----
  	elf64_ia64_reloc_type_lookup
  #define bfd_elf64_bfd_is_local_label_name \
  	elf64_ia64_is_local_label_name
+ #define bfd_elf64_bfd_relax_section \
+ 	elf64_ia64_relax_section
  
  /* Stuff for the BFD linker: */
  #define bfd_elf64_bfd_link_hash_table_create \
Index: bfd/libbfd.h
=================================RCS file: /cvs/cvsfiles/devo/bfd/libbfd.h,v
retrieving revision 1.238.12.1
diff -c -p -d -r1.238.12.1 libbfd.h
*** bfd/libbfd.h	2000/02/17 13:39:42	1.238.12.1
--- bfd/libbfd.h	2000/04/11 08:38:13
*************** static const char *const bfd_reloc_code_
*** 895,900 ****
--- 895,901 ----
    "BFD_RELOC_IA64_PCREL32LSB",
    "BFD_RELOC_IA64_PCREL64MSB",
    "BFD_RELOC_IA64_PCREL64LSB",
+   "BFD_RELOC_IA64_PCREL60L",
    "BFD_RELOC_IA64_LTOFF_FPTR22",
    "BFD_RELOC_IA64_LTOFF_FPTR64I",
    "BFD_RELOC_IA64_LTOFF_FPTR64MSB",
Index: bfd/reloc.c
=================================RCS file: /cvs/cvsfiles/devo/bfd/reloc.c,v
retrieving revision 1.211.12.1
diff -c -p -d -r1.211.12.1 reloc.c
*** bfd/reloc.c	2000/02/17 13:39:43	1.211.12.1
--- bfd/reloc.c	2000/04/11 08:38:13
*************** ENUMX
*** 2721,2726 ****
--- 2721,2728 ----
  ENUMX
    BFD_RELOC_IA64_PCREL64LSB
  ENUMX
+   BFD_RELOC_IA64_PCREL60L
+ ENUMX
    BFD_RELOC_IA64_LTOFF_FPTR22
  ENUMX
    BFD_RELOC_IA64_LTOFF_FPTR64I
Index: include/elf/ia64.h
=================================RCS file: /cvs/cvsfiles/devo/include/elf/ia64.h,v
retrieving revision 1.6
diff -c -p -d -r1.6 ia64.h
*** include/elf/ia64.h	1999/07/16 06:50:31	1.6
--- include/elf/ia64.h	2000/04/11 08:38:23
*************** START_RELOC_NUMBERS (elf_ia64_reloc_type
*** 161,167 ****
  
    RELOC_NUMBER (R_IA64_LTOFF_TP22, 0x9a) /* @ltoff(sym-TP+add), add imm22 ## */
  
!   FAKE_RELOC (R_IA64_MAX_RELOC_CODE, 0x9a)
  END_RELOC_NUMBERS
  
  #endif /* _ELF_IA64_H */
--- 161,172 ----
  
    RELOC_NUMBER (R_IA64_LTOFF_TP22, 0x9a) /* @ltoff(sym-TP+add), add imm22 ## */
  
!   /* ??? This name and value is fake.  Replace it with the real thing once
!      the ABI committee settles on a number.  */
!   RELOC_NUMBER (R_IA64_PCREL60L, 0x101)  /* @pcrel(sym + add), long */
! 
!   FAKE_RELOC (R_IA64_MAX_RELOC_CODE, 0x101)
! 
  END_RELOC_NUMBERS
  
  #endif /* _ELF_IA64_H */
Index: gas/config/tc-ia64.c
=================================RCS file: /cvs/cvsfiles/devo/gas/config/tc-ia64.c,v
retrieving revision 1.40.2.11
diff -c -p -d -r1.40.2.11 tc-ia64.c
*** gas/config/tc-ia64.c	2000/03/30 01:12:16	1.40.2.11
--- gas/config/tc-ia64.c	2000/04/11 08:38:29
*************** operand_match (idesc, index, e)
*** 3991,3999 ****
  	    fix->code = BFD_RELOC_IA64_PCREL21M;
  	  else if (opnd = IA64_OPND_TGT25c)
  	    fix->code = BFD_RELOC_IA64_PCREL21B;
!           else 
!             /* FIXME -- use appropriate relocation type */
!             as_bad (_("long branch targets not implemented"));
  	  fix->code = ia64_gen_real_reloc_type (e->X_op_symbol, fix->code);
  	  fix->opnd = idesc->operands[index];
  	  fix->expr = *e;
--- 3991,4001 ----
  	    fix->code = BFD_RELOC_IA64_PCREL21M;
  	  else if (opnd = IA64_OPND_TGT25c)
  	    fix->code = BFD_RELOC_IA64_PCREL21B;
!           else if (opnd = IA64_OPND_TGT64)
! 	    fix->code = BFD_RELOC_IA64_PCREL60L;
! 	  else
! 	    abort ();
! 
  	  fix->code = ia64_gen_real_reloc_type (e->X_op_symbol, fix->code);
  	  fix->opnd = idesc->operands[index];
  	  fix->expr = *e;
*************** build_insn (slot, insnp)
*** 4210,4295 ****
  
    for (i = 0; i < NELEMS (idesc->operands) && idesc->operands[i]; ++i)
      {
!       if (idesc->operands[i] = IA64_OPND_IMMU64)
  	{
! 	  val = slot->opnd[i].X_add_number;
  	  *insnp++ = (val >> 22) & 0x1ffffffffffLL;
  	  insn |= (((val & 0x7f) << 13) | (((val >> 7) & 0x1ff) << 27)
  		   | (((val >> 16) & 0x1f) << 22) | (((val >> 21) & 0x1) << 21)
  		   | (((val >> 63) & 0x1) << 36));
! 	}
!       else if (idesc->operands[i] = IA64_OPND_IMMU62)
!         {
!           val = slot->opnd[i].X_add_number & 0x3fffffffffffffffULL;
            if (val != slot->opnd[i].X_add_number)
              as_warn (_("Value truncated to 62 bits"));
            *insnp++ = (val >> 21) & 0x1ffffffffffLL;
            insn |= (((val & 0xfffff) << 6) | (((val >> 20) & 0x1) << 36));
!         }
!       else if (idesc->operands[i] = IA64_OPND_TGT64)
!         {
!           // FIXME -- need to implement the target address encoding properly
!           as_bad (_("long branch target encoding not implemented"));
!           *insnp++ = 0;
!         }
!       else if (slot->opnd[i].X_op = O_register
! 	       || slot->opnd[i].X_op = O_constant
! 	       || slot->opnd[i].X_op = O_index
! 	       || slot->opnd[i].X_op = O_big)
! 	{
! 	  if (slot->opnd[i].X_op = O_big)
! 	    {
! 	      /* This must be the value 0x10000000000000000.  */
! 	      assert (idesc->operands[i] = IA64_OPND_IMM8M1U8);
! 	      val = 0;
! 	    }
! 	  else
! 	    val = slot->opnd[i].X_add_number;
  
! 	  switch (idesc->operands[i])
! 	    {
! 	    case IA64_OPND_AR3:				val -= REG_AR; break;
! 	    case IA64_OPND_B1: case IA64_OPND_B2:	val -= REG_BR; break;
! 	    case IA64_OPND_CR3:				val -= REG_CR; break;
! 	    case IA64_OPND_F1: case IA64_OPND_F2:
! 	    case IA64_OPND_F3: case IA64_OPND_F4:	val -= REG_FR; break;
! 	    case IA64_OPND_P1: case IA64_OPND_P2:	val -= REG_P;  break;
  
! 	    case IA64_OPND_R1:	     case IA64_OPND_R2:
! 	    case IA64_OPND_R3:       case IA64_OPND_R3_2:
! 	    case IA64_OPND_CPUID_R3: case IA64_OPND_DBR_R3:
! 	    case IA64_OPND_DTR_R3:   case IA64_OPND_ITR_R3:
! 	    case IA64_OPND_IBR_R3:   case IA64_OPND_MR3:
! 	    case IA64_OPND_MSR_R3:   case IA64_OPND_PKR_R3:
! 	    case IA64_OPND_PMC_R3:   case IA64_OPND_PMD_R3:
! 	    case IA64_OPND_RR_R3:    
! 	      val -= REG_GR;
! 	      break;
  
! 	    default:
! 	      break;
  	    }
! 	  odesc = elf64_ia64_operands + idesc->operands[i];
! 	  err = (*odesc->insert) (odesc, val, &insn);
! 	  if (err)
! 	    as_bad_where (slot->src_file, slot->src_line,
! 			  "Bad operand value: %s", err);
! 	  if (idesc->flags & IA64_OPCODE_PSEUDO)
  	    {
! 	      if ((idesc->flags & IA64_OPCODE_F2_EQ_F3)
! 		  && odesc = elf64_ia64_operands + IA64_OPND_F3)
! 		{
! 		  o2desc = elf64_ia64_operands + IA64_OPND_F2;
! 		  (*o2desc->insert) (o2desc, val, &insn);
! 		      
! 		}
! 	      if ((idesc->flags & IA64_OPCODE_LEN_EQ_64MCNT)
! 		  && (odesc = elf64_ia64_operands + IA64_OPND_CPOS6a
! 		      || odesc = elf64_ia64_operands + IA64_OPND_POS6))
! 		{
! 		  o2desc = elf64_ia64_operands + IA64_OPND_LEN6;
! 		  (*o2desc->insert) (o2desc, 64 - val, &insn);
! 		}
  	    }
  	}
      }
--- 4212,4320 ----
  
    for (i = 0; i < NELEMS (idesc->operands) && idesc->operands[i]; ++i)
      {
!       if (slot->opnd[i].X_op = O_register
! 	  || slot->opnd[i].X_op = O_constant
! 	  || slot->opnd[i].X_op = O_index)
! 	val = slot->opnd[i].X_add_number;
!       else if (slot->opnd[i].X_op = O_big)
  	{
! 	  /* This must be the value 0x10000000000000000.  */
! 	  assert (idesc->operands[i] = IA64_OPND_IMM8M1U8);
! 	  val = 0;
! 	}
!       else
! 	val = 0;
! 
!       switch (idesc->operands[i])
! 	{
! 	case IA64_OPND_IMMU64:
  	  *insnp++ = (val >> 22) & 0x1ffffffffffLL;
  	  insn |= (((val & 0x7f) << 13) | (((val >> 7) & 0x1ff) << 27)
  		   | (((val >> 16) & 0x1f) << 22) | (((val >> 21) & 0x1) << 21)
  		   | (((val >> 63) & 0x1) << 36));
! 	  continue;
! 
! 	case IA64_OPND_IMMU62:
!           val &= 0x3fffffffffffffffULL;
            if (val != slot->opnd[i].X_add_number)
              as_warn (_("Value truncated to 62 bits"));
            *insnp++ = (val >> 21) & 0x1ffffffffffLL;
            insn |= (((val & 0xfffff) << 6) | (((val >> 20) & 0x1) << 36));
! 	  continue;
  
! 	case IA64_OPND_TGT64:
! 	  val >>= 4;
! 	  *insnp++ = ((val >> 20) & 0x7fffffffffLL) << 2;
! 	  insn |= ((((val >> 59) & 0x1) << 36)
! 		   | (((val >> 0) & 0xfffff) << 13));
! 	  continue;
  
! 	case IA64_OPND_AR3:
! 	  val -= REG_AR;
! 	  break;
  
! 	case IA64_OPND_B1:
! 	case IA64_OPND_B2:
! 	  val -= REG_BR;
! 	  break;
! 
! 	case IA64_OPND_CR3:
! 	  val -= REG_CR;
! 	  break;
! 
! 	case IA64_OPND_F1:
! 	case IA64_OPND_F2:
! 	case IA64_OPND_F3:
! 	case IA64_OPND_F4:
! 	  val -= REG_FR;
! 	  break;
! 
! 	case IA64_OPND_P1:
! 	case IA64_OPND_P2:
! 	  val -= REG_P;
! 	  break;
! 
! 	case IA64_OPND_R1:
! 	case IA64_OPND_R2:
! 	case IA64_OPND_R3:
! 	case IA64_OPND_R3_2:
! 	case IA64_OPND_CPUID_R3:
! 	case IA64_OPND_DBR_R3:
! 	case IA64_OPND_DTR_R3:
! 	case IA64_OPND_ITR_R3:
! 	case IA64_OPND_IBR_R3:
! 	case IA64_OPND_MR3:
! 	case IA64_OPND_MSR_R3:
! 	case IA64_OPND_PKR_R3:
! 	case IA64_OPND_PMC_R3:
! 	case IA64_OPND_PMD_R3:
! 	case IA64_OPND_RR_R3:    
! 	  val -= REG_GR;
! 	  break;
! 
! 	default:
! 	  break;
! 	}
! 
!       odesc = elf64_ia64_operands + idesc->operands[i];
!       err = (*odesc->insert) (odesc, val, &insn);
!       if (err)
! 	as_bad_where (slot->src_file, slot->src_line,
! 		      "Bad operand value: %s", err);
!       if (idesc->flags & IA64_OPCODE_PSEUDO)
! 	{
! 	  if ((idesc->flags & IA64_OPCODE_F2_EQ_F3)
! 	      && odesc = elf64_ia64_operands + IA64_OPND_F3)
! 	    {
! 	      o2desc = elf64_ia64_operands + IA64_OPND_F2;
! 	      (*o2desc->insert) (o2desc, val, &insn);
  	    }
! 	  if ((idesc->flags & IA64_OPCODE_LEN_EQ_64MCNT)
! 	      && (odesc = elf64_ia64_operands + IA64_OPND_CPOS6a
! 		  || odesc = elf64_ia64_operands + IA64_OPND_POS6))
  	    {
! 	      o2desc = elf64_ia64_operands + IA64_OPND_LEN6;
! 	      (*o2desc->insert) (o2desc, 64 - val, &insn);
  	    }
  	}
      }
*************** fix_insn (fix, odesc, value)
*** 8051,8057 ****
    slot = fix->fx_where & 0x3;
    fixpos = fix->fx_frag->fr_literal + (fix->fx_where - slot);
  
!   /* bundles are always in little-endian byte order */
    t0 = bfd_getl64 (fixpos);
    t1 = bfd_getl64 (fixpos + 8);
    control_bits = t0 & 0x1f;
--- 8076,8082 ----
    slot = fix->fx_where & 0x3;
    fixpos = fix->fx_frag->fr_literal + (fix->fx_where - slot);
  
!   /* Bundles are always in little-endian byte order */
    t0 = bfd_getl64 (fixpos);
    t1 = bfd_getl64 (fixpos + 8);
    control_bits = t0 & 0x1f;
*************** fix_insn (fix, odesc, value)
*** 8059,8076 ****
    insn[1] = ((t0 >> 46) & 0x3ffff) | ((t1 & 0x7fffff) << 18);
    insn[2] = (t1 >> 23) & 0x1ffffffffffLL;
  
!   err = (*odesc->insert) (odesc, value, insn + slot);
!   if (err)
      {
!       as_bad_where (fix->fx_file, fix->fx_line, err);
!       return;
      }
  
    t0 = control_bits | (insn[0] << 5) | (insn[1] << 46);
    t1 = ((insn[1] >> 18) & 0x7fffff) | (insn[2] << 23);
    md_number_to_chars (fixpos + 0, t0, 8);
    md_number_to_chars (fixpos + 8, t1, 8);
-   
  }
  
  /* Attempt to simplify or even eliminate a fixup.  The return value is
--- 8084,8123 ----
    insn[1] = ((t0 >> 46) & 0x3ffff) | ((t1 & 0x7fffff) << 18);
    insn[2] = (t1 >> 23) & 0x1ffffffffffLL;
  
!   err = NULL;
!   if (odesc - elf64_ia64_operands = IA64_OPND_IMMU64)
      {
!       insn[1] = (value >> 22) & 0x1ffffffffffLL;
!       insn[2] |= (((value & 0x7f) << 13)
! 		  | (((value >> 7) & 0x1ff) << 27)
! 		  | (((value >> 16) & 0x1f) << 22)
! 		  | (((value >> 21) & 0x1) << 21)
! 		  | (((value >> 63) & 0x1) << 36));
!     }
!   else if (odesc - elf64_ia64_operands = IA64_OPND_IMMU62)
!     {
!       if (value & ~0x3fffffffffffffffULL)
! 	err = "integer operand out of range";
!       insn[1] = (value >> 21) & 0x1ffffffffffLL;
!       insn[2] |= (((value & 0xfffff) << 6) | (((value >> 20) & 0x1) << 36));
!     }
!   else if (odesc - elf64_ia64_operands = IA64_OPND_TGT64)
!     {
!       value >>= 4;
!       insn[1] = ((value >> 20) & 0x7fffffffffLL) << 2;
!       insn[2] |= ((((value >> 59) & 0x1) << 36)
! 		  | (((value >> 0) & 0xfffff) << 13));
      }
+   else
+     err = (*odesc->insert) (odesc, value, insn + slot);
+ 
+   if (err)
+     as_bad_where (fix->fx_file, fix->fx_line, err);
  
    t0 = control_bits | (insn[0] << 5) | (insn[1] << 46);
    t1 = ((insn[1] >> 18) & 0x7fffff) | (insn[2] << 23);
    md_number_to_chars (fixpos + 0, t0, 8);
    md_number_to_chars (fixpos + 8, t1, 8);
  }
  
  /* Attempt to simplify or even eliminate a fixup.  The return value is
Index: opcodes/ia64-dis.c
=================================RCS file: /cvs/cvsfiles/devo/opcodes/ia64-dis.c,v
retrieving revision 1.8
diff -c -p -d -r1.8 ia64-dis.c
*** opcodes/ia64-dis.c	2000/01/03 09:32:55	1.8
--- opcodes/ia64-dis.c	2000/04/11 08:38:49
*************** print_insn_ia64 (bfd_vma memaddr, struct
*** 117,123 ****
      {
        /* skip L slot in MLI template: */
        slotnum = 2;
!       retval += slot_multiplier;
      }
  
    insn = slot[slotnum];
--- 117,125 ----
      {
        /* skip L slot in MLI template: */
        slotnum = 2;
!       retval = 16 - slot_multiplier;
!       /* Adjust for the adjustment to be made at the end.  */
!       retval -= 16 - 3*slot_multiplier;
      }
  
    insn = slot[slotnum];
*************** print_insn_ia64 (bfd_vma memaddr, struct
*** 165,170 ****
--- 167,179 ----
              | (((insn >> 36) & 0x1) << 20)
              | ((insn >> 6) & 0xfffff);
          }
+       else if (odesc - elf64_ia64_operands = IA64_OPND_TGT64)
+ 	{
+ 	  /* 60-bit immedate for long branches.  */
+ 	  value = (((insn >> 13) & 0xfffff)
+ 		   | (((insn >> 36) & 1) << 59)
+ 		   | ((slot[1] >> 2) << 20)) << 4;
+ 	}
        else
  	{
  	  err = (*odesc->extract) (odesc, insn, &value);



