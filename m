From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 30 Jun 2004 20:15:30 +0000
Subject: Re: Linker bug in Debian unstable?
Message-Id: <20040630201530.GA27079@lucon.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="jI8keyz6grp/JLjh"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040630192143.GE30334@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040630192143.GE30334@parcelfarce.linux.theplanet.co.uk>
To: linux-ia64@vger.kernel.org


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 30, 2004 at 08:50:18PM +0100, Matthew Wilcox wrote:
> On Wed, Jun 30, 2004 at 12:33:45PM -0700, H. J. Lu wrote:
> > Are you talking about
> > 
> > http://sources.redhat.com/ml/binutils/2004-06/msg00295.html
> 
> Looks like the same problem.  Could you split out the patch so it can
> be applied to the Debian binutils?
> 

That is the one I checked into CVS. I don't know if it will work for
the binutils.


H.J.

--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="binutils-elf-defs-3.patch"

bfd/

2004-03-15  H.J. Lu  <hongjiu.lu@intel.com>

	* elf-bfd.h (RELOC_FOR_GLOBAL_SYMBOL): Report error if
	unresolved symbols in objects aren't allowed.

	* elf-hppa.h (elf_hppa_relocate_section): Properly handle
	unresolved symbols.
	(elf_hppa_remark_useless_dynamic_symbols): Likewise.
	(elf_hppa_unmark_useless_dynamic_symbols):
	* elf32-frv.c (elf32_frv_relocate_section): Likewise.
	* elf32-hppa.c (elf32_hppa_size_stubs): Likewise.
	(elf32_hppa_relocate_section): Likewise.
	* elf32-i370.c (i370_elf_relocate_section): Likewise.
	* elf32-m32r.c (m32r_elf_relocate_section): Likewise.
	* elf32-sh.c (sh_elf_relocate_section): Likewise.
	* elf64-sh64.c (sh_elf64_relocate_section): Likewise.
	* elfxx-mips.c (mips_elf_calculate_relocation): Likewise.

	* elf-m10200.c (mn10200_elf_relocate_section): Use
	RELOC_FOR_GLOBAL_SYMBOL.
	* elf32-avr.c (elf32_avr_relocate_section): Likewise.
	* elf32-d10v.c (elf32_d10v_relocate_section): Likewise.
	* elf32-fr30.c (fr30_elf_relocate_section): Likewise.
	* elf32-h8300.c (elf32_h8_relocate_section): Likewise.
	* elf32-i860.c (elf32_i860_relocate_section): Likewise.
	* elf32-m68hc1x.c (m68hc11_get_relocation_value): Likewise.
	* elf32-mcore.c (mcore_elf_relocate_section): Likewise.
	* elf32-msp430.c (elf32_msp430_relocate_section): Likewise.
	* elf32-openrisc.c (openrisc_elf_relocate_section): Likewise.
	* elf32-v850.c (v850_elf_relocate_section): Likewise.
	* elf32-xstormy16.c (xstormy16_elf_relocate_section): Likewise.
	* elf64-mmix.c (mmix_elf_relocate_section): Likewise.

include/

2004-03-15  H.J. Lu  <hongjiu.lu@intel.com>

	* bfdlink.h (bfd_link_info): Correct comments for the
	unresolved_syms_in_objects field.

ld/

2004-03-15  H.J. Lu  <hongjiu.lu@intel.com>

	* lexsup.c (parse_args): Don't set unresolved_syms_in_objects
	or unresolved_syms_in_shared_libs for -Bdynamic and -Bstatic.

--- binutils/bfd/elf-bfd.h.defs	2004-02-29 21:07:42.000000000 -0800
+++ binutils/bfd/elf-bfd.h	2004-03-17 11:31:19.000000000 -0800
@@ -1757,8 +1757,7 @@ extern bfd_boolean _sh_elf_set_mach_from
 	}														\
       else if (h->root.type == bfd_link_hash_undefweak)									\
 	;														\
-      else if (!info->executable											\
-	       && info->unresolved_syms_in_objects == RM_IGNORE								\
+      else if (info->unresolved_syms_in_objects == RM_IGNORE								\
 	       && ELF_ST_VISIBILITY (h->other) == STV_DEFAULT)								\
 	;														\
       else														\
@@ -1766,8 +1765,7 @@ extern bfd_boolean _sh_elf_set_mach_from
 	  if (! info->callbacks->undefined_symbol									\
 	      (info, h->root.root.string, input_bfd,									\
 	       input_section, rel->r_offset,										\
-	       ((info->shared && info->unresolved_syms_in_shared_libs == RM_GENERATE_ERROR)				\
-		|| (!info->shared && info->unresolved_syms_in_objects == RM_GENERATE_ERROR)				\
+	       (info->unresolved_syms_in_objects == RM_GENERATE_ERROR							\
 		|| ELF_ST_VISIBILITY (h->other))									\
 	       ))													\
 	    return FALSE;												\
--- binutils/bfd/elf-hppa.h.defs	2004-03-17 11:19:23.000000000 -0800
+++ binutils/bfd/elf-hppa.h	2004-03-17 11:31:19.000000000 -0800
@@ -1096,8 +1096,7 @@ elf_hppa_unmark_useless_dynamic_symbols 
      Ultimately we should have better controls over the generic ELF BFD
      linker code.  */
   if (! info->relocatable
-      && ! (info->shared
-	    && info->unresolved_syms_in_shared_libs == RM_IGNORE)
+      && info->unresolved_syms_in_shared_libs != RM_IGNORE
       && h->root.type == bfd_link_hash_undefined
       && (h->elf_link_hash_flags & ELF_LINK_HASH_REF_DYNAMIC) != 0
       && (h->elf_link_hash_flags & ELF_LINK_HASH_REF_REGULAR) == 0)
@@ -1131,8 +1130,7 @@ elf_hppa_remark_useless_dynamic_symbols 
      Ultimately we should have better controls over the generic ELF BFD
      linker code.  */
   if (! info->relocatable
-      && ! (info->shared
-	    && info->unresolved_syms_in_shared_libs == RM_IGNORE)
+      && info->unresolved_syms_in_shared_libs != RM_IGNORE
       && h->root.type == bfd_link_hash_undefined
       && (h->elf_link_hash_flags & ELF_LINK_HASH_REF_DYNAMIC) == 0
       && (h->elf_link_hash_flags & ELF_LINK_HASH_REF_REGULAR) == 0
@@ -1398,16 +1396,9 @@ elf_hppa_relocate_section (bfd *output_b
 	      else
 		relocation = 0;
 	    }
-	  /* Allow undefined symbols in shared libraries.  */
-	  else if (info->shared
-		   && info->unresolved_syms_in_shared_libs == RM_IGNORE
+	  else if (info->unresolved_syms_in_objects == RM_IGNORE
 		   && ELF_ST_VISIBILITY (h->other) == STV_DEFAULT)
 	    {
-	      if (info->symbolic)
-		(*info->callbacks->undefined_symbol)
-		  (info, h->root.root.string, input_bfd,
-		   input_section, rel->r_offset, FALSE);
-
 	      /* If this symbol has an entry in the PA64 dynamic hash
 		 table, then get it.  */
 	      dyn_name = get_dyn_name (input_bfd, h, rel,
@@ -1449,7 +1440,9 @@ elf_hppa_relocate_section (bfd *output_b
 		{
 		  if (!((*info->callbacks->undefined_symbol)
 			(info, h->root.root.string, input_bfd,
-			 input_section, rel->r_offset, TRUE)))
+			 input_section, rel->r_offset,
+			 (info->unresolved_syms_in_objects == RM_GENERATE_ERROR
+			  || ELF_ST_VISIBILITY (h->other)))))
 		    return FALSE;
 		  break;
 		}
--- binutils/bfd/elf-m10200.c.defs	2003-12-04 10:43:50.000000000 -0800
+++ binutils/bfd/elf-m10200.c	2004-03-17 11:31:19.000000000 -0800
@@ -377,28 +377,11 @@ mn10200_elf_relocate_section (output_bfd
 	}
       else
 	{
-	  h = sym_hashes[r_symndx - symtab_hdr->sh_info];
-	  while (h->root.type == bfd_link_hash_indirect
-		 || h->root.type == bfd_link_hash_warning)
-	    h = (struct elf_link_hash_entry *) h->root.u.i.link;
-	  if (h->root.type == bfd_link_hash_defined
-	      || h->root.type == bfd_link_hash_defweak)
-	    {
-	      sec = h->root.u.def.section;
-	      relocation = (h->root.u.def.value
-			    + sec->output_section->vma
-			    + sec->output_offset);
-	    }
-	  else if (h->root.type == bfd_link_hash_undefweak)
-	    relocation = 0;
-	  else
-	    {
-	      if (! ((*info->callbacks->undefined_symbol)
-		     (info, h->root.root.string, input_bfd,
-		      input_section, rel->r_offset, TRUE)))
-		return FALSE;
-	      relocation = 0;
-	    }
+	  bfd_boolean unresolved_reloc, warned;
+
+	  RELOC_FOR_GLOBAL_SYMBOL (h, sym_hashes, r_symndx, symtab_hdr,
+				   relocation, sec, unresolved_reloc,
+				   info, warned);
 	}
 
       r = mn10200_elf_final_link_relocate (howto, input_bfd, output_bfd,
--- binutils/bfd/elf32-avr.c.defs	2003-11-05 08:02:10.000000000 -0800
+++ binutils/bfd/elf32-avr.c	2004-03-17 11:31:19.000000000 -0800
@@ -758,34 +758,11 @@ elf32_avr_relocate_section (output_bfd, 
 	}
       else
 	{
-	  h = sym_hashes [r_symndx - symtab_hdr->sh_info];
+	  bfd_boolean unresolved_reloc, warned;
 
-	  while (h->root.type == bfd_link_hash_indirect
-		 || h->root.type == bfd_link_hash_warning)
-	    h = (struct elf_link_hash_entry *) h->root.u.i.link;
-
-	  name = h->root.root.string;
-
-	  if (h->root.type == bfd_link_hash_defined
-	      || h->root.type == bfd_link_hash_defweak)
-	    {
-	      sec = h->root.u.def.section;
-	      relocation = (h->root.u.def.value
-			    + sec->output_section->vma
-			    + sec->output_offset);
-	    }
-	  else if (h->root.type == bfd_link_hash_undefweak)
-	    {
-	      relocation = 0;
-	    }
-	  else
-	    {
-	      if (! ((*info->callbacks->undefined_symbol)
-		     (info, h->root.root.string, input_bfd,
-		      input_section, rel->r_offset, TRUE)))
-		return FALSE;
-	      relocation = 0;
-	    }
+	  RELOC_FOR_GLOBAL_SYMBOL (h, sym_hashes, r_symndx, symtab_hdr,
+				   relocation, sec, unresolved_reloc,
+				   info, warned);
 	}
 
       r = avr_final_link_relocate (howto, input_bfd, input_section,
--- binutils/bfd/elf32-d10v.c.defs	2004-03-15 09:47:47.000000000 -0800
+++ binutils/bfd/elf32-d10v.c	2004-03-17 11:31:19.000000000 -0800
@@ -517,28 +517,11 @@ elf32_d10v_relocate_section (output_bfd,
 	}
       else
 	{
-	  h = sym_hashes[r_symndx - symtab_hdr->sh_info];
-	  while (h->root.type == bfd_link_hash_indirect
-		 || h->root.type == bfd_link_hash_warning)
-	    h = (struct elf_link_hash_entry *) h->root.u.i.link;
-	  if (h->root.type == bfd_link_hash_defined
-	      || h->root.type == bfd_link_hash_defweak)
-	    {
-	      sec = h->root.u.def.section;
-	      relocation = (h->root.u.def.value
-			    + sec->output_section->vma
-			    + sec->output_offset);
-	    }
-	  else if (h->root.type == bfd_link_hash_undefweak)
-	    relocation = 0;
-	  else
-	    {
-	      if (!((*info->callbacks->undefined_symbol)
-		    (info, h->root.root.string, input_bfd,
-		     input_section, rel->r_offset, TRUE)))
-		return FALSE;
-	      relocation = 0;
-	    }
+	  bfd_boolean unresolved_reloc, warned;
+
+	  RELOC_FOR_GLOBAL_SYMBOL (h, sym_hashes, r_symndx, symtab_hdr,
+				   relocation, sec, unresolved_reloc,
+				   info, warned);
 	}
 
       if (h != NULL)
--- binutils/bfd/elf32-fr30.c.defs	2004-03-15 09:47:47.000000000 -0800
+++ binutils/bfd/elf32-fr30.c	2004-03-17 11:31:19.000000000 -0800
@@ -566,47 +566,11 @@ fr30_elf_relocate_section (output_bfd, i
 	}
       else
 	{
-	  h = sym_hashes [r_symndx - symtab_hdr->sh_info];
+	  bfd_boolean unresolved_reloc, warned;
 
-	  while (h->root.type == bfd_link_hash_indirect
-		 || h->root.type == bfd_link_hash_warning)
-	    h = (struct elf_link_hash_entry *) h->root.u.i.link;
-
-	  name = h->root.root.string;
-
-	  if (h->root.type == bfd_link_hash_defined
-	      || h->root.type == bfd_link_hash_defweak)
-	    {
-	      sec = h->root.u.def.section;
-	      relocation = (h->root.u.def.value
-			    + sec->output_section->vma
-			    + sec->output_offset);
-#if 0
-	      fprintf (stderr,
-		       "defined: sec: %s, name: %s, value: %x + %x + %x gives: %x\n",
-		       sec->name, name, h->root.u.def.value,
-		       sec->output_section->vma, sec->output_offset, relocation);
-#endif
-	    }
-	  else if (h->root.type == bfd_link_hash_undefweak)
-	    {
-#if 0
-	      fprintf (stderr, "undefined: sec: %s, name: %s\n",
-		       sec->name, name);
-#endif
-	      relocation = 0;
-	    }
-	  else
-	    {
-	      if (! ((*info->callbacks->undefined_symbol)
-		     (info, h->root.root.string, input_bfd,
-		      input_section, rel->r_offset, TRUE)))
-		return FALSE;
-#if 0
-	      fprintf (stderr, "unknown: name: %s\n", name);
-#endif
-	      relocation = 0;
-	    }
+	  RELOC_FOR_GLOBAL_SYMBOL (h, sym_hashes, r_symndx, symtab_hdr,
+				   relocation, sec, unresolved_reloc,
+				   info, warned);
 	}
 
       r = fr30_final_link_relocate (howto, input_bfd, input_section,
--- binutils/bfd/elf32-frv.c.defs	2004-03-03 11:49:11.000000000 -0800
+++ binutils/bfd/elf32-frv.c	2004-03-17 11:31:19.000000000 -0800
@@ -1958,16 +1958,16 @@ elf32_frv_relocate_section (output_bfd, 
 	    {
 	      relocation = 0;
 	    }
-	  else if (   ! info->executable
-		   && ! info->symbolic
-		   && info->unresolved_syms_in_objects == RM_IGNORE
+	  else if (info->unresolved_syms_in_objects == RM_IGNORE
 		   && ELF_ST_VISIBILITY (h->other) == STV_DEFAULT)
 	    relocation = 0;
 	  else
 	    {
 	      if (! ((*info->callbacks->undefined_symbol)
 		     (info, h->root.root.string, input_bfd,
-		      input_section, rel->r_offset, TRUE)))
+		      input_section, rel->r_offset,
+		      (info->unresolved_syms_in_objects == RM_GENERATE_ERROR
+		       || ELF_ST_VISIBILITY (h->other)))))
 		return FALSE;
 	      relocation = 0;
 	    }
--- binutils/bfd/elf32-h8300.c.defs	2004-02-09 09:22:27.000000000 -0800
+++ binutils/bfd/elf32-h8300.c	2004-03-17 11:31:19.000000000 -0800
@@ -439,28 +439,11 @@ elf32_h8_relocate_section (bfd *output_b
 	}
       else
 	{
-	  h = sym_hashes[r_symndx - symtab_hdr->sh_info];
-	  while (h->root.type == bfd_link_hash_indirect
-		 || h->root.type == bfd_link_hash_warning)
-	    h = (struct elf_link_hash_entry *) h->root.u.i.link;
-	  if (h->root.type == bfd_link_hash_defined
-	      || h->root.type == bfd_link_hash_defweak)
-	    {
-	      sec = h->root.u.def.section;
-	      relocation = (h->root.u.def.value
-			    + sec->output_section->vma
-			    + sec->output_offset);
-	    }
-	  else if (h->root.type == bfd_link_hash_undefweak)
-	    relocation = 0;
-	  else
-	    {
-	      if (! ((*info->callbacks->undefined_symbol)
-		     (info, h->root.root.string, input_bfd,
-		      input_section, rel->r_offset, TRUE)))
-		return FALSE;
-	      relocation = 0;
-	    }
+	  bfd_boolean unresolved_reloc, warned;
+
+	  RELOC_FOR_GLOBAL_SYMBOL (h, sym_hashes, r_symndx, symtab_hdr,
+				   relocation, sec, unresolved_reloc,
+				   info, warned);
 	}
 
       r = elf32_h8_final_link_relocate (r_type, input_bfd, output_bfd,
--- binutils/bfd/elf32-hppa.c.defs	2003-12-04 10:42:35.000000000 -0800
+++ binutils/bfd/elf32-hppa.c	2004-03-17 11:31:22.000000000 -0800
@@ -2792,8 +2792,7 @@ elf32_hppa_size_stubs
 			}
 		      else if (hash->elf.root.type == bfd_link_hash_undefined)
 			{
-			  if (! (info->shared
-				 && info->unresolved_syms_in_objects == RM_IGNORE
+			  if (! (info->unresolved_syms_in_objects == RM_IGNORE
 				 && (ELF_ST_VISIBILITY (hash->elf.other)
 				     == STV_DEFAULT)
 				 && hash->elf.type != STT_PARISC_MILLI))
@@ -3440,16 +3439,13 @@ elf32_hppa_relocate_section (bfd *output
 	      && hh->root.type != bfd_link_hash_defweak
 	      && hh->root.type != bfd_link_hash_undefweak)
 	    {
-	      if (!info->executable
-		  && info->unresolved_syms_in_objects == RM_IGNORE
+	      if (info->unresolved_syms_in_objects == RM_IGNORE
 		  && ELF_ST_VISIBILITY (hh->other) == STV_DEFAULT
 		  && hh->type == STT_PARISC_MILLI)
 		{
 		  if (! info->callbacks->undefined_symbol
 		      (info, hh->root.root.string, input_bfd,
-		       input_section, rel->r_offset,
-		       ((info->shared && info->unresolved_syms_in_shared_libs == RM_GENERATE_ERROR)
-			|| (!info->shared && info->unresolved_syms_in_objects == RM_GENERATE_ERROR))))
+		       input_section, rel->r_offset, FALSE))
 		    return FALSE;
 		  warned_undef = TRUE;
 		}
--- binutils/bfd/elf32-i370.c.defs	2003-12-04 10:42:35.000000000 -0800
+++ binutils/bfd/elf32-i370.c	2004-03-17 11:31:22.000000000 -0800
@@ -1246,19 +1246,21 @@ i370_elf_relocate_section (output_bfd, i
 	    }
 	  else if (h->root.type == bfd_link_hash_undefweak)
 	    relocation = 0;
-	  else if (info->shared
+	  else if (info->unresolved_syms_in_objects == RM_IGNORE
 		   && ELF_ST_VISIBILITY (h->other) == STV_DEFAULT)
 	    relocation = 0;
 	  else
 	    {
-	      (*info->callbacks->undefined_symbol) (info,
-						    h->root.root.string,
-						    input_bfd,
-						    input_section,
-						    rel->r_offset,
-						    TRUE);
-	      ret = FALSE;
-	      continue;
+	      if ((*info->callbacks->undefined_symbol)
+		  (info, h->root.root.string, input_bfd,
+		   input_section, rel->r_offset,
+		   (info->unresolved_syms_in_objects == RM_GENERATE_ERROR
+		    || ELF_ST_VISIBILITY (h->other))))
+		{
+		  ret = FALSE;
+		  continue;
+		}
+	      relocation = 0;
 	    }
 	}
 
--- binutils/bfd/elf32-i860.c.defs	2004-03-15 10:01:43.000000000 -0800
+++ binutils/bfd/elf32-i860.c	2004-03-17 11:31:22.000000000 -0800
@@ -1112,34 +1112,11 @@ elf32_i860_relocate_section (bfd *output
 	}
       else
 	{
-	  h = sym_hashes [r_symndx - symtab_hdr->sh_info];
+	  bfd_boolean unresolved_reloc, warned;
 
-	  while (h->root.type == bfd_link_hash_indirect
-		 || h->root.type == bfd_link_hash_warning)
-	    h = (struct elf_link_hash_entry *) h->root.u.i.link;
-
-	  name = h->root.root.string;
-
-	  if (h->root.type == bfd_link_hash_defined
-	      || h->root.type == bfd_link_hash_defweak)
-	    {
-	      sec = h->root.u.def.section;
-	      relocation = (h->root.u.def.value
-			    + sec->output_section->vma
-			    + sec->output_offset);
-	    }
-	  else if (h->root.type == bfd_link_hash_undefweak)
-	    {
-	      relocation = 0;
-	    }
-	  else
-	    {
-	      if (! ((*info->callbacks->undefined_symbol)
-		     (info, h->root.root.string, input_bfd,
-		      input_section, rel->r_offset, TRUE)))
-		return FALSE;
-	      relocation = 0;
-	    }
+	  RELOC_FOR_GLOBAL_SYMBOL (h, sym_hashes, r_symndx, symtab_hdr,
+				   relocation, sec, unresolved_reloc,
+				   info, warned);
 	}
 
       switch (r_type)
--- binutils/bfd/elf32-m32r.c.defs	2004-03-17 11:19:28.000000000 -0800
+++ binutils/bfd/elf32-m32r.c	2004-03-17 11:32:50.000000000 -0800
@@ -2773,8 +2773,7 @@ m32r_elf_relocate_section (output_bfd, i
 		}
 	      else if (h->root.type == bfd_link_hash_undefweak)
 		relocation = 0;
-              else if (info->shared
-                       && (!info->symbolic)
+              else if (info->unresolved_syms_in_objects == RM_IGNORE
                        && ELF_ST_VISIBILITY (h->other) == STV_DEFAULT)
                 relocation = 0;
 	      else
@@ -2782,7 +2781,7 @@ m32r_elf_relocate_section (output_bfd, i
 		  if (! ((*info->callbacks->undefined_symbol)
 			 (info, h->root.root.string, input_bfd,
 			  input_section, offset,
-                          (!info->shared
+                          (info->unresolved_syms_in_objects == RM_GENERATE_ERROR
                            || ELF_ST_VISIBILITY (h->other)))))
 		    return FALSE;
 		  relocation = 0;
--- binutils/bfd/elf32-m68hc1x.c.defs	2003-10-06 12:32:20.000000000 -0700
+++ binutils/bfd/elf32-m68hc1x.c	2004-03-17 11:31:23.000000000 -0800
@@ -47,16 +47,6 @@ static void m68hc11_elf_set_symbol (bfd*
 static bfd_boolean m68hc11_elf_export_one_stub
   (struct bfd_hash_entry *gen_entry, void *in_arg);
 
-static bfd_boolean m68hc11_get_relocation_value
-  (bfd* abfd,
-   struct bfd_link_info* info,
-   asection **local_sections,
-   Elf_Internal_Sym* local_syms,
-   Elf_Internal_Rela* rel,
-   const char** name,
-   bfd_vma* relocation,
-   bfd_boolean* is_far);
-
 static void scan_sections_for_abi (bfd*, asection*, PTR);
 
 struct m68hc11_scan_param
@@ -919,7 +909,8 @@ elf32_m68hc11_check_relocs (bfd *abfd, s
 }
 
 static bfd_boolean
-m68hc11_get_relocation_value (bfd *abfd, struct bfd_link_info *info,
+m68hc11_get_relocation_value (bfd *input_bfd, struct bfd_link_info *info,
+			      asection *input_section,
                               asection **local_sections,
                               Elf_Internal_Sym *local_syms,
                               Elf_Internal_Rela *rel,
@@ -934,8 +925,8 @@ m68hc11_get_relocation_value (bfd *abfd,
   Elf_Internal_Sym *sym;
   const char* stub_name = 0;
 
-  symtab_hdr = &elf_tdata (abfd)->symtab_hdr;
-  sym_hashes = elf_sym_hashes (abfd);
+  symtab_hdr = &elf_tdata (input_bfd)->symtab_hdr;
+  sym_hashes = elf_sym_hashes (input_bfd);
 
   r_symndx = ELF32_R_SYM (rel->r_info);
 
@@ -953,33 +944,17 @@ m68hc11_get_relocation_value (bfd *abfd,
       *is_far = (sym && (sym->st_other & STO_M68HC12_FAR));
       if (*is_far)
         stub_name = (bfd_elf_string_from_elf_section
-                     (abfd, symtab_hdr->sh_link,
+                     (input_bfd, symtab_hdr->sh_link,
                       sym->st_name));
     }
   else
     {
-      h = sym_hashes[r_symndx - symtab_hdr->sh_info];
-      while (h->root.type == bfd_link_hash_indirect
-             || h->root.type == bfd_link_hash_warning)
-        h = (struct elf_link_hash_entry *) h->root.u.i.link;
-      if (h->root.type == bfd_link_hash_defined
-          || h->root.type == bfd_link_hash_defweak)
-        {
-          sec = h->root.u.def.section;
-          *relocation = (h->root.u.def.value
-                         + sec->output_section->vma
-                         + sec->output_offset);
-        }
-      else if (h->root.type == bfd_link_hash_undefweak)
-        *relocation = 0;
-      else
-        {
-          if (!((*info->callbacks->undefined_symbol)
-                (info, h->root.root.string, abfd,
-                 sec, rel->r_offset, TRUE)))
-            return FALSE;
-          *relocation = 0;
-        }
+      bfd_boolean unresolved_reloc, warned;
+
+      RELOC_FOR_GLOBAL_SYMBOL (h, sym_hashes, r_symndx, symtab_hdr,
+			       *relocation, sec, unresolved_reloc,
+			       info, warned);
+
       *is_far = (h && (h->other & STO_M68HC12_FAR));
       stub_name = h->root.root.string;
     }
@@ -989,7 +964,7 @@ m68hc11_get_relocation_value (bfd *abfd,
   else
     {
       *name = (bfd_elf_string_from_elf_section
-               (abfd, symtab_hdr->sh_link, sym->st_name));
+               (input_bfd, symtab_hdr->sh_link, sym->st_name));
       if (*name == NULL || **name == '\0')
         *name = bfd_section_name (input_bfd, sec);
     }
@@ -1082,8 +1057,8 @@ elf32_m68hc11_relocate_section (bfd *out
       (*ebd->elf_info_to_howto_rel) (input_bfd, &arel, rel);
       howto = arel.howto;
 
-      m68hc11_get_relocation_value (input_bfd, info,
-                                    local_sections, local_syms,
+      m68hc11_get_relocation_value (input_bfd, info, input_section, 
+				    local_sections, local_syms,
                                     rel, &name, &relocation, &is_far);
 
       /* Do the memory bank mapping.  */
--- binutils/bfd/elf32-mcore.c.defs	2004-03-15 10:16:31.000000000 -0800
+++ binutils/bfd/elf32-mcore.c	2004-03-17 11:31:23.000000000 -0800
@@ -472,30 +472,11 @@ mcore_elf_relocate_section (output_bfd, 
 	}
       else
 	{
-	  h = sym_hashes [r_symndx - symtab_hdr->sh_info];
-	  if (   h->root.type == bfd_link_hash_defined
-	      || h->root.type == bfd_link_hash_defweak)
-	    {
-	      sec = h->root.u.def.section;
-	      relocation = (h->root.u.def.value
-			    + sec->output_section->vma
-			    + sec->output_offset);
-	    }
-	  else if (h->root.type == bfd_link_hash_undefweak)
-	    relocation = 0;
-	  else if (info->shared
-		   && ELF_ST_VISIBILITY (h->other) == STV_DEFAULT)
-	    relocation = 0;
-	  else
-	    {
-	      if (! ((*info->callbacks->undefined_symbol)
-			(info, h->root.root.string, input_bfd,
-		 	 input_section, rel->r_offset, TRUE)))
-		return FALSE;
+	  bfd_boolean unresolved_reloc, warned;
 
-	      ret = FALSE;
-	      continue;
-	    }
+	  RELOC_FOR_GLOBAL_SYMBOL (h, sym_hashes, r_symndx, symtab_hdr,
+				   relocation, sec, unresolved_reloc,
+				   info, warned);
 	}
 
       switch (r_type)
--- binutils/bfd/elf32-msp430.c.defs	2003-11-05 08:02:10.000000000 -0800
+++ binutils/bfd/elf32-msp430.c	2004-03-17 11:31:23.000000000 -0800
@@ -457,33 +457,11 @@ elf32_msp430_relocate_section (output_bf
 	}
       else
 	{
-	  h = sym_hashes[r_symndx - symtab_hdr->sh_info];
+	  bfd_boolean unresolved_reloc, warned;
 
-	  while (h->root.type == bfd_link_hash_indirect
-		 || h->root.type == bfd_link_hash_warning)
-	    h = (struct elf_link_hash_entry *) h->root.u.i.link;
-
-	  name = h->root.root.string;
-
-	  if (h->root.type == bfd_link_hash_defined
-	      || h->root.type == bfd_link_hash_defweak)
-	    {
-	      sec = h->root.u.def.section;
-	      relocation = (h->root.u.def.value
-			    + sec->output_section->vma + sec->output_offset);
-	    }
-	  else if (h->root.type == bfd_link_hash_undefweak)
-	    {
-	      relocation = 0;
-	    }
-	  else
-	    {
-	      if (!((*info->callbacks->undefined_symbol)
-		    (info, h->root.root.string, input_bfd,
-		     input_section, rel->r_offset, TRUE)))
-		return FALSE;
-	      relocation = 0;
-	    }
+	  RELOC_FOR_GLOBAL_SYMBOL (h, sym_hashes, r_symndx, symtab_hdr,
+				   relocation, sec, unresolved_reloc,
+				   info, warned);
 	}
 
       r = msp430_final_link_relocate (howto, input_bfd, input_section,
--- binutils/bfd/elf32-openrisc.c.defs	2003-11-05 08:02:10.000000000 -0800
+++ binutils/bfd/elf32-openrisc.c	2004-03-17 11:31:23.000000000 -0800
@@ -383,33 +383,12 @@ openrisc_elf_relocate_section (output_bf
 	}
       else
 	{
-	  h = sym_hashes[r_symndx - symtab_hdr->sh_info];
+	  bfd_boolean unresolved_reloc, warned;
 
-	  while (h->root.type == bfd_link_hash_indirect
-		 || h->root.type == bfd_link_hash_warning)
-	    h = (struct elf_link_hash_entry *) h->root.u.i.link;
+	  RELOC_FOR_GLOBAL_SYMBOL (h, sym_hashes, r_symndx, symtab_hdr,
+				   relocation, sec, unresolved_reloc,
+				   info, warned);
 
-	  name = h->root.root.string;
-
-	  if (h->root.type == bfd_link_hash_defined
-	      || h->root.type == bfd_link_hash_defweak)
-	    {
-	      sec = h->root.u.def.section;
-	      relocation = (h->root.u.def.value
-			    + sec->output_section->vma + sec->output_offset);
-	    }
-	  else if (h->root.type == bfd_link_hash_undefweak)
-	    {
-	      relocation = 0;
-	    }
-	  else
-	    {
-	      if (!((*info->callbacks->undefined_symbol)
-		    (info, h->root.root.string, input_bfd,
-		     input_section, rel->r_offset, TRUE)))
-		return FALSE;
-	      relocation = 0;
-	    }
 	}
 
       r = openrisc_final_link_relocate (howto, input_bfd, input_section,
--- binutils/bfd/elf32-sh.c.defs	2004-03-03 11:49:11.000000000 -0800
+++ binutils/bfd/elf32-sh.c	2004-03-17 11:31:23.000000000 -0800
@@ -4938,8 +4938,7 @@ sh_elf_relocate_section (bfd *output_bfd
 	    }
 	  else if (h->root.type == bfd_link_hash_undefweak)
 	    relocation = 0;
-	  else if (! info->executable
-		   && info->unresolved_syms_in_objects == RM_IGNORE
+	  else if (info->unresolved_syms_in_objects == RM_IGNORE
 		   && ELF_ST_VISIBILITY (h->other) == STV_DEFAULT)
 	    relocation = 0;
 	  else
@@ -4947,8 +4946,7 @@ sh_elf_relocate_section (bfd *output_bfd
 	      if (! info->callbacks->undefined_symbol
 		  (info, h->root.root.string, input_bfd,
 		   input_section, rel->r_offset,
-		   ((info->shared && info->unresolved_syms_in_shared_libs == RM_GENERATE_ERROR)
-		    || (!info->shared && info->unresolved_syms_in_objects == RM_GENERATE_ERROR)
+		   (info->unresolved_syms_in_objects == RM_GENERATE_ERROR
 		    || ELF_ST_VISIBILITY (h->other))))
 		return FALSE;
 	      relocation = 0;
--- binutils/bfd/elf32-v850.c.defs	2003-12-08 10:01:37.000000000 -0800
+++ binutils/bfd/elf32-v850.c	2004-03-17 11:31:23.000000000 -0800
@@ -1696,43 +1696,11 @@ v850_elf_relocate_section (output_bfd, i
 	}
       else
 	{
-	  h = sym_hashes[r_symndx - symtab_hdr->sh_info];
+	  bfd_boolean unresolved_reloc, warned;
 
-	  while (h->root.type == bfd_link_hash_indirect
-		 || h->root.type == bfd_link_hash_warning)
-	    h = (struct elf_link_hash_entry *) h->root.u.i.link;
-
-	  if (h->root.type == bfd_link_hash_defined
-	      || h->root.type == bfd_link_hash_defweak)
-	    {
-	      sec = h->root.u.def.section;
-	      relocation = (h->root.u.def.value
-			    + sec->output_section->vma
-			    + sec->output_offset);
-#if 0
-	      fprintf (stderr, "defined: sec: %s, name: %s, value: %x + %x + %x gives: %x\n",
-		       sec->name, h->root.root.string, h->root.u.def.value, sec->output_section->vma, sec->output_offset, relocation);
-#endif
-	    }
-	  else if (h->root.type == bfd_link_hash_undefweak)
-	    {
-#if 0
-	      fprintf (stderr, "undefined: sec: %s, name: %s\n",
-		       sec->name, h->root.root.string);
-#endif
-	      relocation = 0;
-	    }
-	  else
-	    {
-	      if (! ((*info->callbacks->undefined_symbol)
-		     (info, h->root.root.string, input_bfd,
-		      input_section, rel->r_offset, TRUE)))
-		return FALSE;
-#if 0
-	      fprintf (stderr, "unknown: name: %s\n", h->root.root.string);
-#endif
-	      relocation = 0;
-	    }
+	  RELOC_FOR_GLOBAL_SYMBOL (h, sym_hashes, r_symndx, symtab_hdr,
+				   relocation, sec, unresolved_reloc,
+				   info, warned);
 	}
 
       /* FIXME: We should use the addend, but the COFF relocations don't.  */
--- binutils/bfd/elf32-xstormy16.c.defs	2003-12-04 10:43:50.000000000 -0800
+++ binutils/bfd/elf32-xstormy16.c	2004-03-17 11:31:23.000000000 -0800
@@ -853,34 +853,11 @@ xstormy16_elf_relocate_section (output_b
 	}
       else
 	{
-	  h = sym_hashes [r_symndx - symtab_hdr->sh_info];
+	  bfd_boolean unresolved_reloc, warned;
 
-	  while (h->root.type == bfd_link_hash_indirect
-		 || h->root.type == bfd_link_hash_warning)
-	    h = (struct elf_link_hash_entry *) h->root.u.i.link;
-
-	  name = h->root.root.string;
-
-	  if (h->root.type == bfd_link_hash_defined
-	      || h->root.type == bfd_link_hash_defweak)
-	    {
-	      sec = h->root.u.def.section;
-	      relocation = (h->root.u.def.value
-			    + sec->output_section->vma
-			    + sec->output_offset);
-	    }
-	  else if (h->root.type == bfd_link_hash_undefweak)
-	    {
-	      relocation = 0;
-	    }
-	  else
-	    {
-	      if (! ((*info->callbacks->undefined_symbol)
-		     (info, h->root.root.string, input_bfd,
-		      input_section, rel->r_offset, TRUE)))
-		return FALSE;
-	      relocation = 0;
-	    }
+	  RELOC_FOR_GLOBAL_SYMBOL (h, sym_hashes, r_symndx, symtab_hdr,
+				   relocation, sec, unresolved_reloc,
+				   info, warned);
 	}
 
       switch (ELF32_R_TYPE (rel->r_info))
--- binutils/bfd/elf64-mmix.c.defs	2004-03-15 10:17:02.000000000 -0800
+++ binutils/bfd/elf64-mmix.c	2004-03-17 11:31:23.000000000 -0800
@@ -1480,39 +1480,11 @@ mmix_elf_relocate_section (output_bfd, i
 	}
       else
 	{
-	  h = sym_hashes [r_symndx - symtab_hdr->sh_info];
+	  bfd_boolean unresolved_reloc;
 
-	  while (h->root.type == bfd_link_hash_indirect
-		 || h->root.type == bfd_link_hash_warning)
-	    h = (struct elf_link_hash_entry *) h->root.u.i.link;
-
-	  name = h->root.root.string;
-
-	  if (h->root.type == bfd_link_hash_defined
-	      || h->root.type == bfd_link_hash_defweak)
-	    {
-	      sec = h->root.u.def.section;
-	      relocation = (h->root.u.def.value
-			    + sec->output_section->vma
-			    + sec->output_offset);
-	    }
-	  else if (h->root.type == bfd_link_hash_undefweak)
-	    relocation = 0;
-	  else if (info->shared
-		   && ELF_ST_VISIBILITY (h->other) == STV_DEFAULT)
-	    relocation = 0;
-	  else
-	    {
-	      /* The test on undefined_signalled is redundant at the
-		 moment, but kept for symmetry.  */
-	      if (! undefined_signalled
-		  && ! ((*info->callbacks->undefined_symbol)
-			(info, h->root.root.string, input_bfd,
-			 input_section, rel->r_offset, TRUE)))
-		return FALSE;
-	      undefined_signalled = TRUE;
-	      relocation = 0;
-	    }
+	  RELOC_FOR_GLOBAL_SYMBOL (h, sym_hashes, r_symndx, symtab_hdr,
+				   relocation, sec, unresolved_reloc,
+				   info, undefined_signalled);
 	}
 
       r = mmix_final_link_relocate (howto, input_section,
--- binutils/bfd/elf64-sh64.c.defs	2003-12-08 10:01:38.000000000 -0800
+++ binutils/bfd/elf64-sh64.c	2004-03-17 11:31:23.000000000 -0800
@@ -1703,15 +1703,16 @@ sh_elf64_relocate_section (bfd *output_b
 	    }
 	  else if (h->root.type == bfd_link_hash_undefweak)
 	    relocation = 0;
-	  else if (info->shared
-		   && !info->symbolic
-		   && info->unresolved_syms_in_objects == RM_IGNORE)
+	  else if (info->unresolved_syms_in_objects == RM_IGNORE
+		   && ELF_ST_VISIBILITY (h->other) == STV_DEFAULT)
 	    relocation = 0;
 	  else
 	    {
 	      if (! ((*info->callbacks->undefined_symbol)
 		     (info, h->root.root.string, input_bfd,
-		      input_section, rel->r_offset, TRUE)))
+		      input_section, rel->r_offset,
+		      (info->unresolved_syms_in_objects == RM_GENERATE_ERROR
+		       || ELF_ST_VISIBILITY (h->other)))))
 		return FALSE;
 	      relocation = 0;
 	    }
--- binutils/bfd/elfxx-mips.c.defs	2004-03-17 11:19:50.000000000 -0800
+++ binutils/bfd/elfxx-mips.c	2004-03-17 11:31:23.000000000 -0800
@@ -3156,8 +3156,7 @@ mips_elf_calculate_relocation (bfd *abfd
 	   and check to see if they exist by looking at their
 	   addresses.  */
 	symbol = 0;
-      else if (info->shared
-	       && info->unresolved_syms_in_objects == RM_IGNORE
+      else if (info->unresolved_syms_in_objects == RM_IGNORE
 	       && ELF_ST_VISIBILITY (h->root.other) == STV_DEFAULT)
 	symbol = 0;
       else if (strcmp (*namep, "_DYNAMIC_LINK") == 0 ||
@@ -3178,9 +3177,8 @@ mips_elf_calculate_relocation (bfd *abfd
 	  if (! ((*info->callbacks->undefined_symbol)
 		 (info, h->root.root.root.string, input_bfd,
 		  input_section, relocation->r_offset,
-		  ((info->shared && info->unresolved_syms_in_shared_libs == RM_GENERATE_ERROR)
-		   || (!info->shared && info->unresolved_syms_in_objects == RM_GENERATE_ERROR)
-		   || ELF_ST_VISIBILITY (h->root.other)))))
+		  (info->unresolved_syms_in_objects == RM_GENERATE_ERROR)
+		   || ELF_ST_VISIBILITY (h->root.other))))
 	    return bfd_reloc_undefined;
 	  symbol = 0;
 	}
--- binutils/include/bfdlink.h.defs	2003-12-05 08:40:20.000000000 -0800
+++ binutils/include/bfdlink.h	2004-03-17 11:31:23.000000000 -0800
@@ -303,9 +303,9 @@ struct bfd_link_info
   unsigned int noexecstack: 1;
 
   /* What to do with unresolved symbols in an object file.
-     When producing static binaries the default is GENERATE_ERROR.
-     When producing dynamic binaries the default is IGNORE.  The
-     assumption with dynamic binaries is that the reference will be
+     When producing executables the default is GENERATE_ERROR.
+     When producing shared libraries the default is IGNORE.  The
+     assumption with shared libraries is that the reference will be
      resolved at load/execution time.  */
   enum report_method unresolved_syms_in_objects;
 
--- binutils/ld/lexsup.c.defs	2003-12-08 10:01:41.000000000 -0800
+++ binutils/ld/lexsup.c	2004-03-17 11:31:23.000000000 -0800
@@ -638,27 +638,9 @@ parse_args (unsigned argc, char **argv)
 	  break;
 	case OPTION_CALL_SHARED:
 	  config.dynamic_link = TRUE;
-	  /* When linking against shared libraries, the default behaviour is
-	     to report any unresolved references.  Although strictly speaking
-	     it is not a failure to encounter unresolved symbols at link time
-	     - the symbol *might* be available at load time - it is a strong
-	     indication that the resulting executable will not work.  Plus it
-	     is necessary for the correct execution of the autoconf package,
-	     which needs to be able to detect functions that are not provided
-	     by the host OS.  */
-	  if (link_info.unresolved_syms_in_objects == RM_NOT_YET_SET)
-	    link_info.unresolved_syms_in_objects = how_to_report_unresolved_symbols;
-	  if (link_info.unresolved_syms_in_shared_libs == RM_NOT_YET_SET)
-	    link_info.unresolved_syms_in_shared_libs = how_to_report_unresolved_symbols;
 	  break;
 	case OPTION_NON_SHARED:
 	  config.dynamic_link = FALSE;
-	  /* When linking against static libraries, the default
-	     behaviour is to report any unresolved references.  */
-	  if (link_info.unresolved_syms_in_objects == RM_NOT_YET_SET)
-	    link_info.unresolved_syms_in_objects = how_to_report_unresolved_symbols;
-	  if (link_info.unresolved_syms_in_shared_libs == RM_NOT_YET_SET)
-	    link_info.unresolved_syms_in_shared_libs = how_to_report_unresolved_symbols;
 	  break;
 	case OPTION_CREF:
 	  command_line.cref = TRUE;

--jI8keyz6grp/JLjh--
