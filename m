From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 21 Mar 2005 22:06:22 +0000
Subject: Re: kernel update (relative to 2.4.29)
Message-Id: <16959.17758.949777.828441@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110843799.4088.38.camel@eeyore>
In-Reply-To: <1110843799.4088.38.camel@eeyore>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 14 Mar 2005 16:43:19 -0700, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> N.B.  While testing this patch, I noticed that the ptrace
  Bjorn> fixes caused anything linked with the profiling libc in
  Bjorn> Debian to fail.  The same thing happens with the current 2.6
  Bjorn> kernel, so I think the problem is most likely in the Debian
  Bjorn> profiling libc.

I looked into this quickly and it's indeed a rather ugly trick in the
mcount stub which caused this issue (my bad).  The simple fix is
attached below.  I submitted the patch to the libc maintainers [1].
Backports to older libcs should be trivial, since that code hasn't
changed in ages.

Thanks,

	--david

[1] http://sources.redhat.com/ml/libc-hacker/2005-03/msg00058.html

ChangeLog

2005-03-21  David Mosberger  <davidm@hpl.hp.com>

	* sysdeps/ia64/_mcount.S: Newer kernels don't like register-frames
	with more than 8 output registers.  Fix this by passing original
	ar.pfs to _mcount_ret_helper via r3.

Index: sysdeps/ia64/_mcount.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/_mcount.S,v
retrieving revision 1.4
diff -u -r1.4 _mcount.S
--- sysdeps/ia64/_mcount.S	6 Jul 2001 04:55:54 -0000	1.4
+++ sysdeps/ia64/_mcount.S	21 Mar 2005 21:15:55 -0000
@@ -72,6 +72,7 @@
 	mov b7 = loc0
 	mov rp = in2
 	;;
+	mov r3 = in0
 	mov r8 = loc2
 	mov r15 = loc3
 	mov b6 = r2
@@ -81,10 +82,10 @@
 LOCAL_LEAF(_mcount_ret_helper)
 	.prologue
 	.altrp b7
-	.save ar.pfs, r40
+	.save ar.pfs, r3
 	.body
-	alloc r2 = ar.pfs, 0, 0, 9, 0
-	mov ar.pfs = r40
+	alloc r2 = ar.pfs, 0, 0, 8, 0
+	mov ar.pfs = r3
 	br b7
 END(_mcount_ret_helper)
 
