From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 03 Apr 2002 22:10:42 +0000
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)
Message-Id: <marc-linux-ia64-105590701905371@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905358@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905358@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 3 Apr 2002 23:29:58 +0200 (MEST), Erich Focht <efocht@ess.nec.de> said:

  Erich> I've seen NaT consumption faults with an ISV application in a
  Erich> loop involving speculative loads, too. It was very hard to
  Erich> trace back (occured at different simulation times in a huge
  Erich> case) and disappeared after we rewrote the loop and used the
  Erich> latest Intel Fortran compiler. It occured with both B3 and C0
  Erich> CPUs under 2.4.7 and 2.4.17. I don't have a testcase for
  Erich> this, sorry.

It's due to a glibc bug that was introduced last August when strncpy()
was rewritten.  I sent a bug report (and preliminary patch) to the
author and am waiting to hear back.

	--david

