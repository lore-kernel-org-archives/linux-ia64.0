From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 04 Apr 2002 19:31:43 +0000
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)
Message-Id: <marc-linux-ia64-105590701905381@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905358@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905358@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 4 Apr 2002 21:27:58 +0200 (MEST), Erich Focht <focht@ess.nec.de> said:

  Erich> What change did you make for strncpy()? Did it somehow
  Erich> produce a NaT somewhere where it could influence a Fortran
  Erich> program? I'd like to understand whether the problem comes
  Erich> from a strange combination of instructions or somehow
  Erich> propagates from glibc.

The glibc routine simply was buggy.  Garbage in, garbage out, not
surprise here.  I suspect your Fortran problem is something entirely
different.

	--david

