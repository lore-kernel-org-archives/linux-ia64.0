From: Tony Luck <tony.luck@intel.com>
Date: Fri, 03 Sep 2010 00:06:33 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <AANLkTimCOWvBs1pdWeMZD9DR=u2ioFPXt7Jja73VQaZn@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz>
	<987664A83D2D224EAE907B061CE93D53015D91D6F5@orsmsx505.amr.corp.intel.com>
	<987664A83D2D224EAE907B061CE93D53015D9B14DC@orsmsx505.amr.corp.intel.com>
	<201008302341.14312.ptesarik@suse.cz>
	<AANLkTin4cn84xu3go-Tj-CYSLp0W6uO1HRtA6_CQu8nJ@mail.gmail.com>
	<AANLkTinHOpcdAJd0_4G=OFAnMZaXKeOsqnbjJMAxCume@mail.gmail.com>
	<AANLkTikUrNcuZB_CFn5cGFovN8U4eyPGL=nEdSP3JS9Z@mail.gmail.com>
	<20100902002641.GI18967@zorg.emea.sgi.com>
In-Reply-To: <20100902002641.GI18967@zorg.emea.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Petr Tesarik <ptesarik@suse.cz>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Today's experiments were inspired by Petr's comment at the start of this thread:

   "Interestingly, CPU 5 and CPU 7 are both granted the same ticket"

I added an "owner" element to every lock - I have 32 cpus, so I made
it "unsigned int". Then added to the lock and trylock paths code to
check that owner was 0 when the lock was granted, followed by:
lock->owner |= (1u << cpu);  Then in the unlock path I check that just
the (1u << cpu) bit is set before doing: lock->owner &= ~(1u << cpu);

In my first test I got a hit. cpu28 had failed to get the lock and was
spinning holding ticket "1". When "now serving" hit 1, cpu28 saw that
the owner field was set to 0x1, indicating that cpu0 had also claimed
the lock. The lockword was 0x20002 at this point ... so cpu28 was
correct to believe that the lock had been freed and handed to it.  It
was unclear why cpu0 had muscled in and set its bit in the owner
field. Also can't tell whether that was a newly allocated lock, or one
that had recently wrapped around.

Subsequent tests have failed to reproduce that result - system just
hangs without complaining about multiple cpus owning the same lock at
the same time - perhaps because of the extra tracing I included to
capture more details.

-Tony
