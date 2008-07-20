From: Russ Anderson <rja@sgi.com>
Date: Sun, 20 Jul 2008 17:50:04 +0000
Subject: Re: [PATCH 0/2] Migrate data off physical pages with corrected memory errors (Version 7)
Message-Id: <20080720175004.GB9409@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080718203514.GD29621@sgi.com> <87prpa88iw.fsf@basil.nowhere.org> <20080719121328.GA20138@parisc-linux.org>
In-Reply-To: <20080719121328.GA20138@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Andi Kleen <andi@firstfloor.org>, mingo@elte.hu, tglx@linutronix.de, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Sat, Jul 19, 2008 at 06:13:28AM -0600, Matthew Wilcox wrote:
> On Sat, Jul 19, 2008 at 12:37:11PM +0200, Andi Kleen wrote:
> > Russ Anderson <rja@sgi.com> writes:
> > 
> > > [PATCH 0/2] Migrate data off physical pages with corrected memory errors (Version 7)
> > 
> > FWIW I discussed this with some hardware people and the general
> > opinion was that it was way too aggressive to disable a page on the
> > first corrected error like this patchkit currently does.  
> 
> I think it's reasonable to take a page out of service on the first error.
> Then a user program needs to be notified of which bit is suspected.
> It can then subject that page to an intense set of tests (I'd start
> by stealing the ones from memtest86+) and if no more errors are found,
> it could return the page to service.

In general I agree with that approach.  One concern is that in the
process of testing the memory the diagnostic may hit an uncorrectable
error.  That is not a problem with Itanium, which is designed to handle
uncorrected/poisoned data going into and out of the processor core, but
can be a system fatal error (requiring a reboot) on other processor types.
Just something to be aware of.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
