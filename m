From: Mark Maule <maule@sgi.com>
Date: Thu, 22 Dec 2005 13:59:24 +0000
Subject: Re: [PATCH 2/4] msi vector targeting abstractions
Message-Id: <20051222135924.GA24232@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051221184337.5003.85653.32527@attica.americas.sgi.com> <20051221184348.5003.7540.53186@attica.americas.sgi.com> <20051221190558.GD2361@parisc-linux.org> <20051221193300.GK9920@sgi.com> <20051222103606.GA29608@infradead.org>
In-Reply-To: <20051222103606.GA29608@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <matthew@wil.cx>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Thu, Dec 22, 2005 at 10:36:06AM +0000, Christoph Hellwig wrote:
> > Mainly I did it this way 'cause msg_address seems to be geared toward specific
> > hw (apic?).  In the case of altix interrupt hw, we don't know about
> > dest_mode et. al., but only care about the raw address.
> 
> In that case you should probably kill the struct as I suggested and only
> keep the shift & mask defines in the file for the apic hw implementation.

Yes, that's what I've done (mostly) for the next patch round.  Still haven't
killed the struct, but at least its isolated to apic code now.

Mark
