From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 05 Mar 2003 02:03:38 +0000
Subject: Re: [Linux-ia64] gcc-3.2 bug
Message-Id: <marc-linux-ia64-105590709805970@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 28 Jan 2003 14:58:28 -0700, Alex Williamson <alex_williamson@hp.com> said:

  Alex>    I've been trying to figure out why agpgart_be.c won't
  Alex> compile on ia64 w/ gcc-3.2, and I've got a pretty simple test
  Alex> case that seems to show a compiler bug.  Not being much of a
  Alex> tools guy, I figured I'd toss it out here.  If I compile with
  Alex> -O2, I get an undefined reference much like I see in the
  Alex> kernel:

  Alex> # gcc -O2 -o test test.c /tmp/ccQCPFMM.o(.text+0xa0): In
  Alex> function `main': : undefined reference to `.L13' collect2: ld
  Alex> returned 1 exit status

  Alex> If I compile w/o optimization or w/ gcc-2.96, it works fine.
  Alex> It also works fine on x86 w/ gcc-3.2.  Here's my gcc info:

Hans tried this with gcc-3.3 and the latest CVS gcc and both worked
fine (I was able to reproduce the bug with 3.2.2).  Looks like the
problem might have been fixed already.

	--david

