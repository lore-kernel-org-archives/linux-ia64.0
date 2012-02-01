From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Wed, 01 Feb 2012 19:58:19 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <20120201195819.76357d79@pyramind.ukuu.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
	<CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
	<1328118174.15992.6206.camel@triegel.csb>
	<CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
In-Reply-To: <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Torvald Riegel <triegel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

> So here's basically what the kernel needs:
> 
>  - if we don't touch a field, the compiler doesn't touch it.
> 
>    This is the rule that gcc now violates with bitfields.
> 
>    This is a gcc bug. End of story. The "volatile" example proves it -
> anybody who argues otherwise is simply wrong, and is just trying to
> make excuses.

C historically didn't make this guarantee because a lot of processors
couldn't make it because they didn't have things like byte accessors (In
fact I suspect early ARM cannot make it for example).

Not meeting it for types where you can do is a bit rude however and
really ought to be an option (speed v sanity).

> See above: it's not the "state" that is accessed concurrently. It's
> the code. If you ever try to mark state, you've already lost. The same
> "state" can be atomic or not depending on context. It's not about the
> state or the data structures, and it never will be.

There are optimisation cases - where you can prove access properties are
safe (eg local variables some times) but they should be exactly that -
optimisations.

Alan
