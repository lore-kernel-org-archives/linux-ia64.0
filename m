From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 03 Nov 2000 21:42:57 +0000
Subject: Re: [Linux-ia64] Re: gdb null ptr
Message-Id: <marc-linux-ia64-105590678205652@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205647@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205647@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>...ia64-linux gdb core dumps on SGI F90 compiler output in tag_type_to_type
>in dwarf2read.c because a NULL nameoftype is passed to strcmp...

The SGI compiler emitted debug info for an array type with the name ".array.".
Gdb ignores DW_AT_name attributes attached to array types.  So we see the
name, try to use the name to index into our type cache, and then fail the
check to weed out hash collisions because we did not save the name in the
type info.

I see 4 ways to fix this:
1) Handle DW_AT_name when attached to an array type.
2) Only cache types that we expect to have names, presumably enums, structures,
   unions, and typedefs.
3) Check for a null string before doing the hash collision check.
4) Use something other than the type name to check for hash collisions.

1 doesn't solve all possible problems, since arrays may not be the only types
with unexpected names.  2 seems like a good choice to me.  3 is inefficient,
because we are storing a value in the cache that we will never be able to use.
I think 4 would require changing struct type to have a pointer back to the
original die, so that we can use a die check for the hash collision check.
This seems like the best choice to me, though it is more work.

Unfortunately, the problem gets a little more complicated.  I looked at the
debug info emitted by the SGI F90 compiler using readelf -w.  The type names
it is using aren't distinct, and hence it is unsafe to use type names for the
hash collision check.  I think there is some sort of C++ template like
expansion going on here (I don't know F90), and instead of using mangled names
for the expanded types it is using the base type name.  I see the same problem
with structure type names.  This may be a problem with the SGI compiler.
Or perhaps it is a problem with gdb not having F90 support yet.

In any case, this is something the gdb developers will have to look at.

Jim

