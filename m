From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 22 Oct 2003 05:48:13 +0000
Subject: Re: [PATCH] Re: Gate DSO not building properly?
MIME-Version: 1
Content-Type: multipart/mixed; boundary="wRRV7LY7NUeQGEoC"
Message-Id: <marc-linux-ia64-106680172513890@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106679437709356@msgid-missing>
In-Reply-To: <marc-linux-ia64-106679437709356@msgid-missing>
To: linux-ia64@vger.kernel.org


--wRRV7LY7NUeQGEoC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Oct 22, 2003 at 01:45:47PM +1000, Ian Wienand wrote:
> On Tue, Oct 21, 2003 at 04:10:51PM +1000, Ian Wienand wrote:
> > arch/ia64/kernel/gate-data.S:1: Warning: setting incorrect section
> > attributes for .data.gate
> 
> I figured out why (sorry if it's obvious); gas matches anything with
> prefix '.data.' as a data special section and flags it as 'SHF_ALLOC +
> SHF_WRITE' as per ELF [*].  Issuing 
> 
> .section .data.gate, "ax"
> 
> thus conflicts as it's assumed to be an extension of a .data section.
> 

Here is a patch for gas. Gas should set the right section attributes
no matter what.


H.J.

--wRRV7LY7NUeQGEoC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="gas-attr-1.patch"

2003-10-21  H.J. Lu  <hongjiu.lu@intel.com>

	* config/obj-elf.c (obj_elf_change_section): Use specified
	section attributes.

--- gas/config/obj-elf.c.attr	2003-09-23 08:16:44.000000000 -0700
+++ gas/config/obj-elf.c	2003-10-21 22:31:51.000000000 -0700
@@ -615,6 +615,7 @@ obj_elf_change_section (name, type, attr
   segT sec;
   flagword flags;
   const struct bfd_elf_special_section *ssect;
+  bfd_boolean override = FALSE;
 
 #ifdef md_flush_pending_output
   md_flush_pending_output ();
@@ -685,10 +686,13 @@ obj_elf_change_section (name, type, attr
 		   && (attr &~ ssect->attr &~ SHF_MERGE &~ SHF_STRINGS) == 0)
 	    ;
 	  else
-	    as_warn (_("setting incorrect section attributes for %s"),
-		     name);
+	    {
+	      as_warn (_("setting incorrect section attributes for %s"),
+		       name);
+	      override = TRUE;
+	    }
 	}
-      if (old_sec == NULL)
+      if (!override && old_sec == NULL)
 	attr |= ssect->attr;
     }
 

--wRRV7LY7NUeQGEoC--
