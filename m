From: "Ross A. Towle" <rat@cchkms.engr.sgi.com>
Date: Wed, 18 Oct 2000 01:49:29 +0000
Subject: [Linux-ia64] running ia32 binaries with same .so names as ia64
Message-Id: <marc-linux-ia64-105590678205587@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since Perl is not working for the SPEC harness, I have brought over
specperl that SPEC2000 distribution disk which is for RedHat6.0 and
later.

When I run it looks for an IA32 libgdbm.so.2 and reports "error in loading
shared libraries: libgdbm.so.2: ELF file class not 32-bit". So I copied it from
a IA32 box from /usr/lib and put it in /usr/i386-glibc21-linux/usr/lib.  This
still does not fix the problem (same error message).  But if I put it in
/usr/lib/temp and set LD_LIBRARY_PATH to /usr/lib/temp:$LD_LIBRARY_PATH
then everything runs fine.

Any ideas on how to do this without the LD_LIBRARY_PATH?

To generalize,  if I want to bring over a IA32 binary linked against
some .so's with the same name(s) as on IA64, where do I place the IA32 .so's so
they are found without setting LD_LIBRARY_PATH?

-Ross

