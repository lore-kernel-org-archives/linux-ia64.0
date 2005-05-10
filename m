From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 May 2005 18:26:17 +0000
Subject: Re: KDB improvements for IA64
Message-Id: <17024.64713.827619.735000@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4280D2C5.3060604@bull.net>
In-Reply-To: <4280D2C5.3060604@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 10 May 2005 17:27:01 +0200, Francois Wellenreiter <Francois.Wellenreiter@bull.net> said:

  Francois> - timeouts when exiting from KDB will never occur I have
  Francois> noticed that after a long time in KDB, some drivers enter
  Francois> in timeout sequences. Now, the different ITC values are
  Francois> saved when entering KDB and restored when going out.

This sounds fragile to me.  For one thing, the kernel may not use ITC
at all for timeouts (true for most NUMA platforms).  Also, even if the
ITC is in use, you'd probably have to resync them on the slave CPUs
after restoring the time-keeper's ITC value.  Not to mention that if
the timeout is related to an external event, then faking time won't
help no matter what.

	--david
