From: Hedi Berriche <hedi@sgi.com>
Date: Thu, 02 Sep 2010 00:26:41 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <20100902002641.GI18967@zorg.emea.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <987664A83D2D224EAE907B061CE93D53015D91D6F5@orsmsx505.amr.corp.intel.com> <987664A83D2D224EAE907B061CE93D53015D9B14DC@orsmsx505.amr.corp.intel.com> <201008302341.14312.ptesarik@suse.cz> <AANLkTin4cn84xu3go-Tj-CYSLp0W6uO1HRtA6_CQu8nJ@mail.gmail.com> <AANLkTinHOpcdAJd0_4G=OFAnMZaXKeOsqnbjJMAxCume@mail.gmail.com> <AANLkTikUrNcuZB_CFn5cGFovN8U4eyPGL=nEdSP3JS9Z@mail.gmail.com>
In-Reply-To: <AANLkTikUrNcuZB_CFn5cGFovN8U4eyPGL=nEdSP3JS9Z@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Sep 02, 2010 at 00:10 Tony Luck wrote:
| More results from other experiments ...
| 
| 1) It occurred to me that I should check that these test cases weren't
| hitting some other problem in 2.6.36-rc3. So I ported the 64-bit
| version of ticket locks to the current kernel and ran the stress test.
| It was still going strong at 16 hours (where all my other experiments
| tend to fail at 90 minutes or less).

This is consistent with the bisection that led me to the 4 bytes ticket
locks commit.

| Summary: the only change that helps is the 64-bit ticket locks.

Ditto.

Cheers,
Hedi.
-- 
Hedi Berriche
Global Product Support
http://www.sgi.com/support
