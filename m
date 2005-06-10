From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 10 Jun 2005 10:32:05 +0000
Subject: Re: [PATCH 00/10] IOCHK interface for I/O error handling/detecting
Message-Id: <42A96C25.9050903@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A8386F.2060100@jp.fujitsu.com> <20050609173433.GE24611@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050609173433.GE24611@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

Matthew Wilcox wrote:
> On Thu, Jun 09, 2005 at 09:39:11PM +0900, Hidetoshi Seto wrote:
> 
>>Reflecting every comments, I brushed up my patch for generic part.
>>So today I'll post it again, and also post "ia64 part", which
>>surely implements ia64-arch specific error checking. I think
>>latter will be a sample of basic implement for other arch.
> 
> I think this is the wrong way to go about it.  For PCI Express, we
> have a defined cross-architecture standard which tells us exactly how
> all future PCIe devices will behave in the face of errors.  For PCI and
> PCI-X, we have a lot of legacy systems, each of which implements error
> checking and recovery in a somewhat eclectic way.
> 
> So, IMO, any implementation of PCI error recovery should start by
> implementing the PCI Express AER mechanisms and then each architecture can
> look at extending that scheme to fit their own legacy hardware systems.
> That way we have a clean implementation for the future rather than being
> tied to any one manufacturer or architecture's quirks.
> 
> Also, we can evaluate it based on looking at what the standard says,
> rather than all trying to wrap our brains around the idiosyncracies of
> a given platform ;-)

All right, please take it a example of approach from legacy-side.

Already there are good working group, includes Linas, BenH, and Long.
They are also implementing some PCI error recovery codes (currently
setting home to ppc64), and I know their wonderful works are more PCI
Express friendly than my mysterious ia64 works :-)

However, I also know that it doesn't mean my works were useless.
Since there is a notable difference between their asynchronous error
recovery and my synchronous error detecting, both could live in
coexistence with each other.

How cooperate with is interesting coming agenda, I think.

Thanks,
H.Seto

