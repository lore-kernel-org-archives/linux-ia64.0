From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 12 Jan 2001 02:13:02 +0000
Subject: Re: [Linux-ia64] The 1117 snapshot alignment bug
Message-Id: <marc-linux-ia64-105590693005035@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005029@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005029@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes, it is a compiler bug.  It is a generic problem effecting all targets,
though it is more noticable for 64-bit machines.  Not clear when it was
introduced, I didn't want to spend that much time looking at the problem.
The bug was independently found and fixed by Richard Kenner last week.

Tue Jan  2 10:47:38 2001  Richard Kenner  <kenner@vlsi1.ultra.nyu.

	* expr.c (store_constructor_field): Update ALIGN before calling
	store_constructor.

Index: expr.c
=================================RCS file: /cvs/cvsfiles/devo/gcc/expr.c,v
retrieving revision 1.425.2.2
diff -p -r1.425.2.2 expr.c
*** expr.c	2000/08/14 20:10:41	1.425.2.2
--- expr.c	2001/01/12 02:04:27
*************** store_constructor_field (target, bitsize
*** 4224,4229 ****
--- 4224,4233 ----
  			    ? BLKmode : VOIDmode,
  			    plus_constant (XEXP (target, 0),
  					   bitpos / BITS_PER_UNIT));
+ 
+       if (bitpos != 0)
+ 	align = MIN (align, bitpos & - bitpos);
+ 
        store_constructor (exp, target, align, cleared, bitsize / BITS_PER_UNIT);
      }
    else

