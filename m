From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 22 Nov 2000 02:18:50 +0000
Subject: Re: [Linux-ia64] 001117 toolchain release
Message-Id: <marc-linux-ia64-105590678205762@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205748@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205748@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Why 16 bytes?  The sections only have 8 byte data.  (Technically, the unwind
section has 4 byte data for the 32-bit ABI, but I'm ignoring that for now.)

I added this patch to the FSF binutils sources to fix the problem.  I am not
planning to add a patch for the 001117 release, since this doesn't seem to
be a serious enough problem.

2000-11-21  Jim Wilson  <wilson@redhat.com>

	* config/tc-ia64.c (generate_unwind_image): Call record_alignment
	for unwind info section.
	(dot_endp): Likewise for unwind section.

Index: tc-ia64.c
=================================RCS file: /cvs/src/src/gas/config/tc-ia64.c,v
retrieving revision 1.33
diff -p -r1.33 tc-ia64.c
*** tc-ia64.c	2000/11/22 01:12:05	1.33
--- tc-ia64.c	2000/11/22 02:01:42
*************** generate_unwind_image ()
*** 3057,3062 ****
--- 3057,3065 ----
        expressionS exp;
        set_section ((char *) special_section_name[SPECIAL_SECTION_UNWIND_INFO]);
  
+       /* Make sure the section has 8 byte alignment.  */
+       record_alignment (now_seg, 3);
+ 
        /* Set expression which points to start of unwind descriptor area.  */
        unwind.info = expr_build_dot ();
  
*************** dot_endp (dummy)
*** 3684,3689 ****
--- 3687,3696 ----
    unwind.proc_end = expr_build_dot ();
  
    set_section ((char *) special_section_name[SPECIAL_SECTION_UNWIND]);
+ 
+   /* Make sure the section has 8 byte alignment.  */
+   record_alignment (now_seg, 3);
+ 
    ptr = frag_more (24);
    where = frag_now_fix () - 24;
    bytes_per_address = bfd_arch_bits_per_address (stdoutput) / 8;



