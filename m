From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 16 Jan 2001 00:42:26 +0000
Subject: Re: [Linux-ia64] [PATCH] Fix for kernel DRM build
Message-Id: <marc-linux-ia64-105590693005047@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205902@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205902@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>     ld: drivers/char/drm/drm.o: linking 64-bit files with 32-bit
>     files
>     ld: drivers/char/drm/drm.o: linking constant-gp files with
>     non-constant-gp files

I've sent a proposed patch to binutils@sources.redhat.com for comment.

I don't like HJ's proposed solution, which is to ignore the ELF header flags
if an object file is empty.  That can mask real errors, as this ar/ld -r
trick is not the only way to create empty object files.

My proposed patch fixes the linker to notice when the output file is empty,
and then we set the ELF header flags from the first member of the first
archive even though we aren't linking it in.  This fixes the kernel build
failure.  Alternatively, it might be better to check the ELF header flags
of every member of every archive to avoid ambiguity, but that seemed like
unnecessary extra work so I won't do that unless the binutils maintainers
request it.

Here is my proposed patch.


2001-01-15  Jim Wilson  <wilson@redhat.com>

	* ldlang.c (lang_check): If file_chain.head is NULL, then find first
	member of first archive, and call bfd_merge_private_bfd_data on it.

Index: ldlang.c
=================================RCS file: /cvs/cvsfiles/devo/ld/ldlang.c,v
retrieving revision 1.289
diff -p -r1.289 ldlang.c
*** ldlang.c	2000/07/10 11:46:54	1.289
--- ldlang.c	2001/01/16 00:03:58
*************** lang_check ()
*** 3477,3482 ****
--- 3477,3507 ----
  	    bfd_set_error_handler (pfn);
  	}
      }
+ 
+   /* There can be no used input files if the only inputs are archives.
+      In that case, arbitrarily pick the first element of the first archive
+      and use that one to initialize private bfd data.  This construct occurs
+      in the linux kernel, and if we don't have the bfd_merge_private_bfd_data
+      call, we can get errors in the final link.  */
+   if (file_chain.head = NULL)
+     {
+       lang_input_statement_type *f;
+ 
+       for (f = (lang_input_statement_type *) input_file_chain.head;
+ 	   f != NULL;
+ 	   f = (lang_input_statement_type *) f->next_real_file)
+ 	{
+ 	  if (f->the_bfd
+ 	      && bfd_check_format (f->the_bfd, bfd_archive))
+ 	    {
+ 	      bfd *member;
+ 
+ 	      member = bfd_openr_next_archived_file (f->the_bfd, (bfd *) NULL);
+ 	      bfd_merge_private_bfd_data (member, output_bfd);
+ 	      break;
+ 	    }
+ 	}
+     }
  }
  
  /* Look through all the global common symbols and attach them to the


