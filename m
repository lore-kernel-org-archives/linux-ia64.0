From: Andi Kleen <andi@firstfloor.org>
Date: Sat, 19 Jul 2008 15:06:49 +0000
Subject: Re: [PATCH 0/2] Migrate data off physical pages with corrected memory errors (Version 7)
Message-Id: <87ljzx9aly.fsf@basil.nowhere.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080718203514.GD29621@sgi.com>
	<87prpa88iw.fsf@basil.nowhere.org>
	<20080719121328.GA20138@parisc-linux.org>
In-Reply-To: <20080719121328.GA20138@parisc-linux.org> (Matthew Wilcox's message of "Sat, 19 Jul 2008 06:13:28 -0600")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Russ Anderson <rja@sgi.com>, mingo@elte.hu, tglx@linutronix.de, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Matthew Wilcox <matthew@wil.cx> writes:

> On Sat, Jul 19, 2008 at 12:37:11PM +0200, Andi Kleen wrote:
>> Russ Anderson <rja@sgi.com> writes:
>> 
>> > [PATCH 0/2] Migrate data off physical pages with corrected memory errors (Version 7)
>> 
>> FWIW I discussed this with some hardware people and the general
>> opinion was that it was way too aggressive to disable a page on the
>> first corrected error like this patchkit currently does.  
>
> I think it's reasonable to take a page out of service on the first error.
> Then a user program needs to be notified of which bit is suspected.
> It can then subject that page to an intense set of tests (I'd start
> by stealing the ones from memtest86+) and if no more errors are found,
> it could return the page to service.

That would only really help if really only parts of that specific page
is corrupted.  But my understanding is that DIMM failures usually
cluster in larger units (channels, DIMMs, memory chips on them, banks
inside the chips etc., all far larger than a 4K page)

So to do your proposal you would need to do this on the units of whole
DIMMs or at least their pages, otherwise it is somewhat
pointless. Since the memory systems typically interleave this would
likely need to be done on multiple DIMMs, potentially covering a large
memory area.

In the end you'll end up with most of the mess of memory hot unplug
because the more memory is affected the more likely it is 
some unmoveable kernel data is affected.

-Andi
