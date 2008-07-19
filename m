From: Matthew Wilcox <matthew@wil.cx>
Date: Sat, 19 Jul 2008 12:13:28 +0000
Subject: Re: [PATCH 0/2] Migrate data off physical pages with corrected memory errors (Version 7)
Message-Id: <20080719121328.GA20138@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080718203514.GD29621@sgi.com> <87prpa88iw.fsf@basil.nowhere.org>
In-Reply-To: <87prpa88iw.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <andi@firstfloor.org>
Cc: Russ Anderson <rja@sgi.com>, mingo@elte.hu, tglx@linutronix.de, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Sat, Jul 19, 2008 at 12:37:11PM +0200, Andi Kleen wrote:
> Russ Anderson <rja@sgi.com> writes:
> 
> > [PATCH 0/2] Migrate data off physical pages with corrected memory errors (Version 7)
> 
> FWIW I discussed this with some hardware people and the general
> opinion was that it was way too aggressive to disable a page on the
> first corrected error like this patchkit currently does.  

I think it's reasonable to take a page out of service on the first error.
Then a user program needs to be notified of which bit is suspected.
It can then subject that page to an intense set of tests (I'd start
by stealing the ones from memtest86+) and if no more errors are found,
it could return the page to service.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
