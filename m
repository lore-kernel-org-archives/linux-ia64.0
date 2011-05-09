From: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Date: Mon, 09 May 2011 22:26:39 +0000
Subject: Re: [PATCH] Don't mlock guardpage if the stack is growing up
Message-Id: <alpine.DEB.2.00.1105100025300.13325@artax.karlin.mff.cuni.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.2.00.1105082045250.15552@artax.karlin.mff.cuni.cz> <alpine.LSU.2.00.1105081303540.16151@sister.anvils> <alpine.DEB.2.00.1105091307570.32299@artax.karlin.mff.cuni.cz> <BANLkTinCUQSjjif3op3H_9HDm5Eu-o+Luw@mail.gmail.com>
 <BANLkTim3kKJkisZK1mOgKhsEEs7FzZmyXA@mail.gmail.com>
In-Reply-To: <BANLkTim3kKJkisZK1mOgKhsEEs7FzZmyXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, linux-ia64@vger.kernel.org



On Mon, 9 May 2011, Linus Torvalds wrote:

> On Mon, May 9, 2011 at 8:57 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > Hmm. One thing that strikes me is this problem also implies that the
> > /proc/self/maps file is wrong for the GROWSUP case, isn't it?
> >
> > So I think we should not just apply your lock fix, but then *also*
> > apply something like this:
> 
> Actually, I think we might be better off with something like this.
> 
> It makes a few more changes:
> 
>  - move the stack guard page checking in __get_user_pages() into the
> rare case (ie we didn't find a page), since that's the only case we
> care about (the thing about the guard page is that don't want to call
> "handle_mm_fault()"). As a result, it's off any path where we can
> possibly care about performance, so we might as well have a nice
> helper function for both the grow-up and grow-down cases, instead of
> trying to be clever and only look at the grow-down case for the first
> page in the vma like you did in your patch.
> 
>    End result: simpler, more straightforward code.
> 
>  - Move the growsup/down helper functions to <linux/mm.h>, since the
> /proc code really wants to use them too. That means that the
> "vma_stack_continue()" function (which now got split up into two
> cases, for the up/down cases) is now entirely just an internal helper
> function - nobody else uses it, and the real interface are the
> "stack_guard_page_xyz()"  functions. Renamed to be simpler.
> 
>  - changed that naming of those stack_guard_page functions to use
> _start and _end instead of growsup/growsdown, since it actually takes
> the start or the end of the page as the argument (to match the
> semantics of the afore-mentioned helpers)
> 
>  - and finally, make /proc/<pid>/maps use these helpers for both the
> up/down case, so now /proc/self/maps should work well for the growsup
> case too.
> 
> Hmm?
> 
> The only oddish case is IA64 that actually has a stack that grows
> *both* up and down. That means that I could make up a stack mapping
> that has a single virtual page in it, that is both the start *and* the
> end page. Now /proc/self/maps would actually show such a mapping with
> "negative" size. That's interesting.
> 
> It would be easy enough to have a "if (end < start) end = start" there
> for that case, but maybe it's actually interesting information.
> 
> Regardless, I'd like to hear whether this patch really does work on
> PA-RISC and especially IA64. I think those are the only cases that
> have a GROWSUP stack. And the IA64 case that supports both is the most
> interesting, everybody else does just one or the other.
> 
>                     Linus

I will test it after a week, now I'm traveling away.

Mikulas
