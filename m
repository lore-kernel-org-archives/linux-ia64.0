From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 23 Aug 2007 16:14:42 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <alpine.LFD.0.999.0708230913470.30176@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
	<200708221202.12403.jesse.barnes@intel.com>
	<20070823022043.GB18788@wotan.suse.de>
	<alpine.LFD.0.999.0708221953360.30176@woody.linux-foundation.org>
	<20070823035448.GG18788@wotan.suse.de>
In-Reply-To: <20070823035448.GG18788@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>
Cc: linux-ia64@vger.kernel.org, Jesse Barnes <jesse.barnes@intel.com>, linuxppc-dev@ozlabs.org



On Thu, 23 Aug 2007, Nick Piggin wrote:
> 
> OK, but we'd have some kind of functions that are called not to
> serialise the CPUs, but to serialise the IO. It would be up to
> the calling code to already provide CPU synchronisation.
> 
> serialize_io(); / unserialize_io(); / a nicer name

We could call it "mmiowb()", for example?

Radical idea, I know.

> If we could pass in some kind of relevant resoure (eg. the IO
> memory or device or something), then we might even be able to
> put debug checks there to ensure two CPUs are never inside the
> same critical IO section at once.

We could certainly give it the spinlock as an argument.

		Linus
