From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 15 May 2003 16:03:48 +0000
Subject: Re: [Linux-ia64] Itanium 2 flaw detection
Message-Id: <marc-linux-ia64-105590723705829@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705820@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705820@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 15 May 2003 10:37:40 +0200, Bruno Cornec <Bruno.Cornec@hp.com> said:

  Bruno> Hello, Concerning the recent problem announced by Intel on
  Bruno> some I2 chips, do anyone of you have a pointer to a script/C
  Bruno> Code/whatever code which could give a clear answer for the
  Bruno> processor on which we are running ?  (I didn't had customer
  Bruno> requests up yo now, but I prefer to be early :-)

I don't, but I'd like to have it, too. ;-/

  Bruno> Would it be also possible to include it in the result of
  Bruno> /proc/cpuinfo as it was done for pentium processor bugs some
  Bruno> time ago:

  Bruno> [bruno@morley ~/Download]$ cat /proc/cpuinfo [...]  fdiv_bug
  Bruno> : no hlt_bug : no f00f_bug : no coma_bug : no [...]

That only makes sense for bugs for which the kernel can do something
about.  That's not the case here because there is no way for the
kernel to force the clock frequency down to 800MHz.

	--david

