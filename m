From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 23 Aug 2007 16:27:42 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <1187886462.5972.17.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
	<200708221202.12403.jesse.barnes@intel.com>
	<20070823022043.GB18788@wotan.suse.de>
	<alpine.LFD.0.999.0708221953360.30176@woody.linux-foundation.org>
	<20070823042038.GI18788@wotan.suse.de>
	<alpine.LFD.0.999.0708230915000.30176@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.0.999.0708230915000.30176@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-ia64@vger.kernel.org, Jesse Barnes <jesse.barnes@intel.com>, linuxppc-dev@ozlabs.org

On Thu, 2007-08-23 at 09:16 -0700, Linus Torvalds wrote:
> 
> On Thu, 23 Aug 2007, Nick Piggin wrote:
> > 
> > Also, FWIW, there are some advantages of deferring the mmiowb thingy
> > until the point of unlock.
> 
> And that is exactly what ppc64 does.
> 
> But you're missing a big point: for 99.9% of all hardware, mmiowb() is a 
> total no-op. So when you talk about "advantages", you're not talking about 
> any *real* advantage, are you?

I wonder whether it might be worth removing mmiowb and having all archs
that matter do like ppc64 though... It's just yet another confusing
barrier that most driver writers get wrong..

Cheers,
Ben.


