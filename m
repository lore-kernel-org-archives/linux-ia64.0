From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 06 Aug 2002 20:23:38 +0000
Subject: Re: [Linux-ia64] utime emulation
Message-Id: <marc-linux-ia64-105590701905918@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905917@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905917@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 6 Aug 2002 12:01:15 -0700, "Wichmann, Mats D" <mats.d.wichmann@intel.com> said:

  Mats> I'm finding that utime(filename, NULL) doesn't follow specs -
  Mats> this comes up in plodding through the LSB certification test
  Mats> suite.

  Mats> For example, if the process does not own the file but has
  Mats> write permission, the above referenced call should succeed but
  Mats> fails with EPERM.

  Mats> utime() is emulated on Itanium: in the kernel, fs/open.c
  Mats> doesn't have a sys_utime routine if __ia64__ or alpha; the
  Mats> emulation comes from glibc's sysdeps/unix/utime.c but appears
  Mats> to be bogus.  The problem is that if the second argument to
  Mats> utime is NULL the emulation code does some work to build up a
  Mats> "struct timeval" array as expected by utimes(), and passes
  Mats> that off, instead of passing NULL... and so the proper checks
  Mats> in the NULL case don't get done by the kernel.

  Mats> I guess this is a query to see if anyone on this list knows
  Mats> anything about this code.  Is this just a glibc problem, or
  Mats> should Itanium go back to providing the non-emulated utime
  Mats> routine like nearly all the other arch's do (and so this
  Mats> emulation code is not run).

Please report this as a glibc bug.

	--david

