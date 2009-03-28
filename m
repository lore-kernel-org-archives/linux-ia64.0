From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 28 Mar 2009 20:59:28 +0000
Subject: Re: [GIT PULL] percpu, cpumask, x86 updates for v2.6.30
Message-Id: <20090328205928.GA3955@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LFD.2.00.0903281341100.3994@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0903281341100.3994@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sat, 28 Mar 2009, Ingo Molnar wrote:
> > 
> > Below is this tree merged against latest -git, resolving two new 
> > conflicts. I forgot to mention that the percpu/MM changes are 
> > fine by Andrew too.
> 
> Ingo, I think you ia64 stuff was broken. It used "vector" to get 
> to the irq descriptor. Which is not the same as an "irq" at all.
> 
> The reason I noticed is that it clashed with the ia64 pull, which 
> had fixed this up.
> 
> I tried to fix it all up. But I'm just about the last person in 
> the universe who wants to compile ia64, so I have not tested, or 
> even been able to see that it compiles.  Somebody should 
> double-check it.

Sure, i'm on it, i'll check your resolution of 
arch/ia64/kernel/irq_ia64.c.

	Ingo
