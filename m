From: "Vegard Nossum" <vegard.nossum@gmail.com>
Date: Sat, 05 Jul 2008 18:41:39 +0000
Subject: Re: the printk problem
Message-Id: <19f34abd0807051141h4ccfd0ar28660199f2bbf81f@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080705125230.GA20166@damson.getinternet.no>
	 <alpine.LFD.1.10.0807051045520.2815@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.10.0807051045520.2815@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Engelhardt <jengelh@medozas.de>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew@wil.cx>, Peter Anvin <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org

On Sat, Jul 5, 2008 at 7:56 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Sat, 5 Jul 2008, Vegard Nossum wrote:
>> On Sat, Jul 5, 2008 at 1:33 PM, Jan Engelhardt <jengelh@medozas.de> wrote:
>> > How about %p{feature}?
>
> No.
>
> I _expressly_ chose '%p[alphanumeric]*' because it's basically
> totally insane to have that in a *real* printk() string: the end result
> would be totally unreadable.
>
> In contrast, '%p[specialchar]' is not unreadable, and in fact we have lots
> of those already in the kernel. In fact, there are 40 occurrences of '%p{'
> in the kernel, just grep for it (especially the AFS code seems to be very
> happy to use that kind of printout in its debug statements).
>
> So it makes perfect sense to have a _real_ printk string that says
>
>        "BUG: Dentry %p{i=%lx,n=%s}"
>
> where we have that '%p{...' sequence: the end result is easily parseable.
> In contrast, anybody who uses '%pS' or something like that and expects a
> pointer name to be immediately followed by teh letter 'S' is simply
> insane, because the end result is an unreadable mess.

That's really a truly hideous hack :-)

Single letters are bad because it hurts readability and limits the
usefulness of the extension.</MHO>

If it's just the {} that is the problem, use something else. I'm sure
we can find something that isn't used already.

>
>> (It's hard on the stack, yes, I know. We should fix kallsyms.)
>
> Not just that, but it's broken when KALLSYMS is disabled. Look at what
> sprint_symbol() becomes.

Oops. Not hard to mend, though.

> The patch I already sent out is about a million times better, because it
> avoids all these issues, and knows about subtle issues like the difference
> between a direct pointer and a pointer to a function descriptor.

Right, right. I found it now:

http://ozlabs.org/pipermail/linuxppc-dev/2008-July/059257.html

Argh... Some pointer to original thread would be nice when adding new Ccs.


Vegard

PS: Your version has exactly the same stack problem. Will send a patch
for kallsyms later.

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
