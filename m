From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 09 Sep 2008 22:05:18 +0000
Subject: Re: [PATCH] Correct printk %pF to work on all architectures
Message-Id: <1220997918.4879.392.camel@pasglop>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220481754.3254.42.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0809031546310.3515@nehalem.linux-foundation.org>
	 <1220482853.3254.47.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0809031602270.3515@nehalem.linux-foundation.org>
	 <1220484812.3254.59.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0809031636320.3515@nehalem.linux-foundation.org>
	 <1220492616.3254.64.camel@localhost.localdomain>
	 <1220567811.4879.85.camel@pasglop>
	 <57C9024A16AD2D4C97DC78E552063EA30A0DC383@orsmsx505.amr.corp.intel.com>
	 <1220969561.3334.7.camel@localhost.localdomain>
	 <20080909180840.GA1940@phobos.i.cabal.ca>
In-Reply-To: <20080909180840.GA1940@phobos.i.cabal.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kyle McMartin <kyle@mcmartin.ca>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Luck, Tony" <tony.luck@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>

On Tue, 2008-09-09 at 14:08 -0400, Kyle McMartin wrote:
> On Tue, Sep 09, 2008 at 09:12:41AM -0500, James Bottomley wrote:
> > OK, so could we get this in to -rc5 please?  It's a bug fix for parisc
> > since we're currently printing rubbish.
> > 
> 
> While I suppose it's a "parisc" patch, I'm not going to try to push it
> unless either Linus just applies it, or we get an ack from the ppc/ia64
> folks too.
> 
> ... That said, please apply it, Linus. :)
> 
> Acked-by: Kyle McMartin <kyle@mcmartin.ca>

Got one from us already but here it is again

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Cheers,
Ben.


