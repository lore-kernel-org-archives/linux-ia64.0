From: Andi Kleen <ak@suse.de>
Date: Mon, 20 Sep 2004 20:57:53 +0000
Subject: Re: page fault scalability patch V8: [4/7] universally available cmpxchg on i386
Message-Id: <20040920205752.GH4242@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com> <200409191430.37444.vda@port.imtp.ilyichevsk.odessa.ua> <Pine.LNX.4.58.0409200844460.3633@schroedinger.engr.sgi.com> <200409202043.00580.vda@port.imtp.ilyichevsk.odessa.ua> <Pine.LNX.4.58.0409201348070.4628@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0409201348070.4628@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>, akpm@osdl.org, "David S. Miller" <davem@davemloft.net>, benh@kernel.crashing.org, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, ak@muc.de, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

On Mon, Sep 20, 2004 at 01:49:20PM -0700, Christoph Lameter wrote:
> On Mon, 20 Sep 2004, Denis Vlasenko wrote:
> 
> > I think it shouldn't be this way.
> >
> > OTOH for !CONFIG_386 case it makes perfect sense to have it inlined.
> 
> Would the following revised patch be acceptable?

You would need an EXPORT_SYMBOL at least. But to be honest your
original patch was much simpler and nicer and cmpxchg is not called
that often that it really matters. I would just ignore Denis' 
suggestion and stay with the old patch.

-Andi
