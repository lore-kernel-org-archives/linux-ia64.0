From: "Wichmann, Mats D" <mats.d.wichmann@intel.com>
Date: Tue, 06 Aug 2002 19:01:15 +0000
Subject: [Linux-ia64] utime emulation
Message-Id: <marc-linux-ia64-105590701905917@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm finding that utime(filename, NULL) doesn't
follow specs - this comes up in plodding through
the LSB certification test suite.

For example, if the process does not own the
file but has write permission, the above
referenced call should succeed but fails with EPERM.

utime() is emulated on Itanium: in the kernel,
fs/open.c doesn't have a sys_utime routine 
if __ia64__ or alpha; the emulation comes from
glibc's sysdeps/unix/utime.c but appears to
be bogus.  The problem is that if the second
argument to utime is NULL the emulation code
does some work to build up a "struct timeval"
array as expected by utimes(), and passes that
off, instead of passing NULL... and so the
proper checks in the NULL case don't get done
by the kernel.

I guess this is a query to see if anyone
on this list knows anything about this code.
Is this just a glibc problem, or should Itanium
go back to providing the non-emulated utime
routine like nearly all the other arch's do
(and so this emulation code is not run).


Mats Wichmann

