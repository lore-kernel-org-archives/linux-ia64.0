From: Daniel Berlin <dberlin@redhat.com>
Date: Sat, 04 Nov 2000 03:20:47 +0000
Subject: Re: [Linux-ia64] Re: gdb null ptr
Message-Id: <marc-linux-ia64-105590678205654@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205647@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205647@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kevin Buettner <kevinb@cygnus.com> writes:

> 
> Nice analysis.
> 
> The patch below effectively implements Jim's suggestion #2 above. 
> This patch was made with respect to sourceware and might not apply
> cleanly to sources from which the current linux/ia64 gdb is being
> built.  (I can provide such patches if desired however.)
> 
> I've tested it against the program provided by Pete Wyckoff and
> it does fix the segfault.
> 
> I will leave it to the dwarf2 maintainers to decide whether this
> patch is acceptable or if it would be better to implement one of
> Jim's other suggestions.
> 

Unfortuantely , this is actually still wrong for languages other than
C++, because we don't have the same guarantees about uniqueness in the name.

I was actually in the process of readying patches that add the same
type of name based caching (based on mangled name) to partial and
normal symbol reading, which gives us an amazing win for C++.

These patches also moved all of the name caching into "if (cu_language
= language_cplus)" blocks, doing what we used to do in the old case
(IE no caching).

Rather than let this stay broken until i finish cleaning up those
patches, here is a patch that moves the type caching so it only
happens for C++ CU's.

Unless other languages make the same guarantees, we can't do the same
optimization.

Diff is making it into more than it is, because moving it into the
cu_language = language_cplus block, changes the indentation of all
the code under it.

I have added the same type of code kevin has to the patches i am
readying.


--Dan


Index: dwarf2read.c
=================================RCS file: /cvs/src/src/gdb/dwarf2read.c,v
retrieving revision 1.17
diff -c -3 -p -r1.17 dwarf2read.c
*** dwarf2read.c	2000/11/03 22:38:38	1.17
--- dwarf2read.c	2000/11/04 03:05:24
*************** tag_type_to_type (struct die_info *die, 
*** 4532,4547 ****
        attr = dwarf_attr (die, DW_AT_name);
        if (attr && DW_STRING (attr))
  	{
! 	  char *attrname=DW_STRING (attr);
! 	  unsigned long hashval=hash(attrname, strlen(attrname)) % TYPE_HASH_SIZE;
! 
! 	  if (dwarf2_cached_types[hashval] != NULL)
  	    {
! 	      const char *nameoftype;
! 	      nameoftype = TYPE_NAME(dwarf2_cached_types[hashval]) = NULL ? TYPE_TAG_NAME(dwarf2_cached_types[hashval]) : TYPE_NAME(dwarf2_cached_types[hashval]);
! 	      if (strcmp(attrname, nameoftype) = 0)
  		{
! 		  die->type=dwarf2_cached_types[hashval];
  		}
  	      else
  		{
--- 4532,4554 ----
        attr = dwarf_attr (die, DW_AT_name);
        if (attr && DW_STRING (attr))
  	{
! 	  if (cu_language = language_cplus)
  	    {
! 	      char *attrname=DW_STRING (attr);
! 	      unsigned long hashval=hash(attrname, strlen(attrname)) % TYPE_HASH_SIZE;
! 	      if (dwarf2_cached_types[hashval] != NULL)
  		{
! 		  const char *nameoftype;
! 		  nameoftype = TYPE_NAME(dwarf2_cached_types[hashval]) = NULL ? TYPE_TAG_NAME(dwarf2_cached_types[hashval]) : TYPE_NAME(dwarf2_cached_types[hashval]);
! 		  if (strcmp(attrname, nameoftype) = 0)
! 		    {
! 		      die->type=dwarf2_cached_types[hashval];
! 		    }
! 		  else
! 		    {
! 		      read_type_die (die, objfile, cu_header);
! 		      dwarf2_cached_types[hashval] = die->type;
! 		    }
  		}
  	      else
  		{
*************** tag_type_to_type (struct die_info *die, 
*** 4552,4558 ****
  	  else
  	    {
  	      read_type_die (die, objfile, cu_header);
- 	      dwarf2_cached_types[hashval] = die->type;
  	    }
  	}
        else
--- 4559,4564 ----


