From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 18 Jan 2001 00:39:49 +0000
Subject: Re: [Linux-ia64] two ICEs with current compiler
Message-Id: <marc-linux-ia64-105590693005071@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005066@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005066@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>gcc -DSTDC_HEADERS=1 -I. -I. -I.. -O2 -I/usr/lib/glib/include -I/usr/X11R6/include -c gdkgl.c  -fPIC -DPIC -o .libs/gdkgl.lo
>gdkgl.c: In function `gdk_gl_pixmap_unref':
>gdkgl.c:318: Internal compiler error in `clear_by_pieces', at expr.c:2335
>Please submit a full bug report.
>See <URL:http://www.gnu.org/software/gcc/bugs.html> for instructions.

For the first problem, the code is passing a pointer to an incomplete type
to __builtin_memset.  Internally, gcc set the alignment of incomplete types
to 1 bit.  __builtin_memset then fails because it doesn't know how to copy
anything with less then 8-bit (char) alignment.

This was fixed by changing the default alignment to the same as char.

2000-10-26  Nathan Sidwell  <nathan@codesourcery.com>

	* tree.c (make_node, case 't'): Set alignment to that of
	char_type_node.

Index: tree.c
=================================RCS file: /cvs/cvsfiles/devo/gcc/tree.c,v
retrieving revision 1.197
diff -p -r1.197 tree.c
*** tree.c	2000/07/14 17:46:32	1.197
--- tree.c	2001/01/18 00:24:51
*************** make_node (code)
*** 1076,1082 ****
  
      case 't':
        TYPE_UID (t) = next_type_uid++;
!       TYPE_ALIGN (t) = 1;
        TYPE_USER_ALIGN (t) = 0;
        TYPE_MAIN_VARIANT (t) = t;
        TYPE_OBSTACK (t) = obstack;
--- 1076,1082 ----
  
      case 't':
        TYPE_UID (t) = next_type_uid++;
!       TYPE_ALIGN (t) = char_type_node ? TYPE_ALIGN (char_type_node) : 0;
        TYPE_USER_ALIGN (t) = 0;
        TYPE_MAIN_VARIANT (t) = t;
        TYPE_OBSTACK (t) = obstack;

