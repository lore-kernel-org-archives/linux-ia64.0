From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 24 Oct 2003 15:15:48 +0000
Subject: Re: [PATCH] Re: Gate DSO not building properly?
Message-Id: <marc-linux-ia64-106700871221668@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106679437709356@msgid-missing>
In-Reply-To: <marc-linux-ia64-106679437709356@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 24, 2003 at 11:07:22AM +0100, Nick Clifton wrote:
> 
>         
> > +  bfd_boolean override = FALSE;
> 
> [optional]: This variable could be moved inside the if statement
> starting at line 672, localizing it, if the statement was changed to:
> 
>   if (old_sec = NULL)
>     {
>       bfd_boolean override = FALSE;
> 
>       if (attr & ~ ssect->attr)
>         {
>         ...
>         }
> 
>       if (!override)
> 	attr |= ssect->attr;
>   }      
> 
> I feel that the code looks neater this way.
> 
>      
> >  		   && (attr &~ ssect->attr &~ SHF_MERGE &~ SHF_STRINGS) = 0)
> 
> I would appreciate it if you could add a space between the '&' and the
> '~'.  These are separate operators and should not be juxtaposed like
> that.  I know that this is not part of your original patch, but since
> we are modifying this area of code, I think that it would be a good
> idea to clean this up.
> 
> 
> > +	      as_warn (_("setting incorrect section attributes for %s"),
> > +		       name);
> > +	      override = TRUE;
> 
> Since the new attributes are going to be ignored, we should change the
> warning message appropriately.  Something like:
> 
> 	      as_warn (_("ignoring setting of incorrect section attributes for %s"),

The attributes got ignored are the default ones. We are setting user-
specified, "incorrect" attributes according to special_sections in
bfd/elf.c.

I will check in the patch enclosed here.


H.J.
----
2003-10-24  H.J. Lu  <hongjiu.lu@intel.com>

	* config/obj-elf.c (obj_elf_change_section): Allow SHF_ALLOC
	for .interp, .strtab and .symtab. Use specified section
	attributes.

--- gas/config/obj-elf.c.attr	2003-09-23 08:16:44.000000000 -0700
+++ gas/config/obj-elf.c	2003-10-24 08:08:29.000000000 -0700
@@ -641,6 +641,8 @@ obj_elf_change_section (name, type, attr
 
   if (ssect != NULL)
     {
+      bfd_boolean override = FALSE;
+
       if (type = SHT_NULL)
 	type = ssect->type;
       else if (type != ssect->type)
@@ -669,7 +671,7 @@ obj_elf_change_section (name, type, attr
 	    }
 	}
 
-      if (old_sec = NULL && (attr &~ ssect->attr) != 0)
+      if (old_sec = NULL && (attr & ~ssect->attr) != 0)
 	{
 	  /* As a GNU extension, we permit a .note section to be
 	     allocatable.  If the linker sees an allocatable .note
@@ -682,13 +684,25 @@ obj_elf_change_section (name, type, attr
 	     something like .rodata.str.  */
 	  else if (ssect->suffix_length = -2
 		   && name[ssect->prefix_length] = '.'
-		   && (attr &~ ssect->attr &~ SHF_MERGE &~ SHF_STRINGS) = 0)
+		   && (attr
+		       & ~ssect->attr
+		       & ~SHF_MERGE
+		       & ~SHF_STRINGS) = 0)
 	    ;
+	  /* .interp, .strtab and .symtab can have SHF_ALLOC.  */
+	  else if (attr = SHF_ALLOC
+		   && (strcmp (name, ".interp") = 0
+		       || strcmp (name, ".strtab") = 0
+		       || strcmp (name, ".symtab") = 0))
+	    override = TRUE;
 	  else
-	    as_warn (_("setting incorrect section attributes for %s"),
-		     name);
+	    {
+	      as_warn (_("setting incorrect section attributes for %s"),
+		       name);
+	      override = TRUE;
+	    }
 	}
-      if (old_sec = NULL)
+      if (!override && old_sec = NULL)
 	attr |= ssect->attr;
     }
 
