From: Tony Luck <tony.luck@intel.com>
Date: Wed, 01 Sep 2010 23:09:18 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <AANLkTikUrNcuZB_CFn5cGFovN8U4eyPGL=nEdSP3JS9Z@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz>
	<987664A83D2D224EAE907B061CE93D53015D91D6F5@orsmsx505.amr.corp.intel.com>
	<987664A83D2D224EAE907B061CE93D53015D9B14DC@orsmsx505.amr.corp.intel.com>
	<201008302341.14312.ptesarik@suse.cz>
	<AANLkTin4cn84xu3go-Tj-CYSLp0W6uO1HRtA6_CQu8nJ@mail.gmail.com>
	<AANLkTinHOpcdAJd0_4G=OFAnMZaXKeOsqnbjJMAxCume@mail.gmail.com>
In-Reply-To: <AANLkTinHOpcdAJd0_4G=OFAnMZaXKeOsqnbjJMAxCume@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: Hedi Berriche <hedi@sgi.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

More results from other experiments ...

1) It occurred to me that I should check that these test cases weren't
hitting some other problem in 2.6.36-rc3. So I ported the 64-bit
version of ticket locks to the current kernel and ran the stress test.
It was still going strong at 16 hours (where all my other experiments
tend to fail at 90 minutes or less).

2) Next I investigated whether wrap-around was related by reducing
TICKET_BITS from 15 to 8 (I only have 32 cpus, so this should be
plenty). I also moved the bit offset of the "now serving" value to
different spots in the high half of the lock to check whether we were
hitting some issues with overflow from the fetchadd on the low half
into the high half, or some sign problem when bit 31 was set.  These
tests all failed in 20 minutes to an hour (not significantly different
from TICKET_BITS) ... so wraparound appears not to be an issue.

3) Then I wondered whether it was a problem that we used fetchadd4
which modifies all 32 bits in an atomic instruction when acquiring the
lock, but a simple st2 to write just the upper 16 bits when doing the
unlock. So I recoded __ticket_spin_unlock() to spin on a cmpxchg call
to update all 32-bits with an atomic instruction. This one failed in
34 minutes.

4) Memory ordering? I added ia64_mf() calls liberally throughout all
the __ticket_* routines. Kernel failed in 32 minutes.

Summary: the only change that helps is the 64-bit ticket locks.

-Tony
