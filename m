From: Andi Kleen <ak@suse.de>
Date: Thu, 23 Sep 2004 09:03:45 +0000
Subject: Re: page fault scalability patch V8: [4/7] universally available cmpxchg on i386
Message-Id: <20040923090345.GA6146@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0409201348070.4628@schroedinger.engr.sgi.com> <20040920205752.GH4242@wotan.suse.de> <200409211841.25507.vda@port.imtp.ilyichevsk.odessa.ua> <20040921154542.GB12132@wotan.suse.de> <41527885.8020402@myrealbox.com>
In-Reply-To: <41527885.8020402@myrealbox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Lutomirski <luto@myrealbox.com>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, "David S. Miller" <davem@davemloft.net>, benh@kernel.crashing.org, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, ak@muc.de, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

> Wouldn't alternative_input() choosing between a cmpxchg and a call be 
> the way to go here?  Or is the overhead too high in an inline function?

It would if you want the absolute micro optimization yes. Disadvantage
is that you would waste some more space for nops in the !CONFIG_I386 case.
I personally don't think it matters much and that Christian's original
code was just fine.

-Andi (last post on the thread) 
