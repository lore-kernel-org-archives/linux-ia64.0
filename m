From: Kevin Buettner <kevinb@cygnus.com>
Date: Fri, 03 Nov 2000 23:02:54 +0000
Subject: Re: [Linux-ia64] Re: gdb null ptr
Message-Id: <marc-linux-ia64-105590678205653@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205647@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205647@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Nov 3,  1:42pm, Jim Wilson wrote:

> The SGI compiler emitted debug info for an array type with the name ".array.".
> Gdb ignores DW_AT_name attributes attached to array types.  So we see the
> name, try to use the name to index into our type cache, and then fail the
> check to weed out hash collisions because we did not save the name in the
> type info.
> 
> I see 4 ways to fix this:
> 1) Handle DW_AT_name when attached to an array type.
> 2) Only cache types that we expect to have names, presumably enums, structures,
>    unions, and typedefs.
> 3) Check for a null string before doing the hash collision check.
> 4) Use something other than the type name to check for hash collisions.
> 
> 1 doesn't solve all possible problems, since arrays may not be the only types
> with unexpected names.  2 seems like a good choice to me.  3 is inefficient,
> because we are storing a value in the cache that we will never be able to use.
> I think 4 would require changing struct type to have a pointer back to the
> original die, so that we can use a die check for the hash collision check.
> This seems like the best choice to me, though it is more work.
> 
> Unfortunately, the problem gets a little more complicated.  I looked at the
> debug info emitted by the SGI F90 compiler using readelf -w.  The type names
> it is using aren't distinct, and hence it is unsafe to use type names for the
> hash collision check.  I think there is some sort of C++ template like
> expansion going on here (I don't know F90), and instead of using mangled names
> for the expanded types it is using the base type name.  I see the same problem
> with structure type names.  This may be a problem with the SGI compiler.
> Or perhaps it is a problem with gdb not having F90 support yet.

Nice analysis.

The patch below effectively implements Jim's suggestion #2 above. 
This patch was made with respect to sourceware and might not apply
cleanly to sources from which the current linux/ia64 gdb is being
built.  (I can provide such patches if desired however.)

I've tested it against the program provided by Pete Wyckoff and
it does fix the segfault.

I will leave it to the dwarf2 maintainers to decide whether this
patch is acceptable or if it would be better to implement one of
Jim's other suggestions.

	* dwarf2read.c (tag_type_to_type): Don't cache the type
	unless it has a name or a tag name.

Index: dwarf2read.c
=================================RCS file: /cvs/src/src/gdb/dwarf2read.c,v
retrieving revision 1.17
diff -u -p -r1.17 dwarf2read.c
--- dwarf2read.c	2000/11/03 22:38:38	1.17
+++ dwarf2read.c	2000/11/03 22:45:19
@@ -4538,7 +4538,9 @@ tag_type_to_type (struct die_info *die, 
 	  if (dwarf2_cached_types[hashval] != NULL)
 	    {
 	      const char *nameoftype;
-	      nameoftype = TYPE_NAME(dwarf2_cached_types[hashval]) = NULL ? TYPE_TAG_NAME(dwarf2_cached_types[hashval]) : TYPE_NAME(dwarf2_cached_types[hashval]);
+	      nameoftype = TYPE_NAME(dwarf2_cached_types[hashval]) = NULL 
+	                    ? TYPE_TAG_NAME(dwarf2_cached_types[hashval])
+			    : TYPE_NAME(dwarf2_cached_types[hashval]);
 	      if (strcmp(attrname, nameoftype) = 0)
 		{
 		  die->type=dwarf2_cached_types[hashval];
@@ -4546,13 +4548,17 @@ tag_type_to_type (struct die_info *die, 
 	      else
 		{
 		  read_type_die (die, objfile, cu_header);
-		  dwarf2_cached_types[hashval] = die->type;
+ 		  if (TYPE_NAME (die->type) != NULL 
+ 		      || TYPE_TAG_NAME (die->type) != NULL)
+ 		    dwarf2_cached_types[hashval] = die->type;
 		}
 	    }
 	  else
 	    {
 	      read_type_die (die, objfile, cu_header);
-	      dwarf2_cached_types[hashval] = die->type;
+ 	      if (TYPE_NAME (die->type) != NULL 
+ 		  || TYPE_TAG_NAME (die->type) != NULL)
+ 		dwarf2_cached_types[hashval] = die->type;
 	    }
 	}
       else


