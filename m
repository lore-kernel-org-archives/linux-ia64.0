From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 Feb 2004 22:29:10 +0000
Subject: Re: [patch] 2.6.2-rc2 Remove compile warnings from timer.o
Message-Id: <16425.23350.962126.469241@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040205061136.GD25002@cse.unsw.EDU.AU>
In-Reply-To: <20040205061136.GD25002@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 5 Feb 2004 17:11:36 +1100, Darren Williams <dsw@gelato.unsw.edu.au> said:

  Darren> This ia a relatively simple patch to remove compile
  Darren> warnings: kernel/timer.c: In function `second_overflow':
  Darren> kernel/timer.c:589: warning: right shift count is negative
  Darren> kernel/timer.c:592: warning: right shift count is negative

  Darren> when CONFIG_IA64_HP_SIM=y.

  Darren> Tested with SIM boots and compile.

  Darren> -#  define HZ	  32
  Darren> +#  define HZ	  96

Doesn't strike me as the correct fix: looking at timex.h, clearly HZ
values as low as 12Hz are supposed to be supported.  Perhaps a better
fix would be to change timer.c to verify that
SHIFT_SCALE<=SHIFT_USEC+SHIFT_HZ before attempting to do the shifting
(via a CPP #if, of course).

Also, I'm a bit reluctant to increase the HZ value for the simulator,
because too large a value will cause the simulated kernel to fail to
make forward progress on slow host machines.

	--david
