From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 13 May 2005 21:46:12 +0000
Subject: PATCH: Don't allow ia64 unwind section to point to section in different files
Message-Id: <20050513214612.GA31765@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 13, 2005 at 02:05:56PM -0700, David Mosberger wrote:
> >>>>> On Fri, 13 May 2005 14:01:11 -0700, "H. J. Lu" <hjl@lucon.org> said:
> 
>   >> However, there still seems to be a binutils issues here: if this
>   >> is something binutils cannot properly support, it should issue an
>   >> error, not silently generate wrong code, no?
> 
>   HJ> I will see what I can do.
> 

When weak functions are used on ia64, part of the unwind section may
point to the strong definition in a different file. This will lead to
wrong unwind info. Basically, on ia64, we have to use comdat to get the
right unwind info. This patch will check it.


H.J.
---
2005-05-13  H.J. Lu  <hongjiu.lu@intel.com>

	* elfxx-ia64.c (elfNN_ia64_relocate_section): Don't allow
	unwind section to point to section in different files.

--- bfd/elfxx-ia64.c.weak	2005-05-13 10:47:56.000000000 -0700
+++ bfd/elfxx-ia64.c	2005-05-13 14:44:52.000000000 -0700
@@ -4151,6 +4151,27 @@ elfNN_ia64_relocate_section (output_bfd,
       value += rel->r_addend;
       dynamic_symbol_p = elfNN_ia64_dynamic_symbol_p (h, info, r_type);
 
+      /* The unwind section and the corresponding text section have
+	 to come from the same file.  When the strong function overides
+	 a weak function, part of the unwind section may point to the
+	 wrong place.  */
+      if (h
+	  && (h->root.type = bfd_link_hash_defined
+	      || h->root.type = bfd_link_hash_defweak)
+	  && (elf_section_data (input_section)->this_hdr.sh_type
+	      = SHT_IA_64_UNWIND)
+	  && input_section->owner != h->root.u.def.section->owner)
+	{
+	  (*_bfd_error_handler)
+	    (_("%B: unwind section `%A' points to symbol `%s' defined in section '%A' in %B"),
+	     input_bfd, input_section, h->root.u.def.section,
+	     h->root.u.def.section->owner,
+	     h ? h->root.root.string
+	       : bfd_elf_sym_name (input_bfd, symtab_hdr, sym, sym_sec));
+	  ret_val = FALSE;
+	  continue;
+	}
+
       switch (r_type)
 	{
 	case R_IA64_NONE:
