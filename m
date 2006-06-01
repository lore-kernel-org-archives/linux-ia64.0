From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 01 Jun 2006 01:20:17 +0000
Subject: Re: Montecito processor family
Message-Id: <20060601012017.GA32143@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <42ADD890.1010406@free.fr>
In-Reply-To: <42ADD890.1010406@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 31, 2006 at 05:03:27PM -0700, Luck, Tony wrote:
> Digging up this from the distant past (November, 2005): 
> 
> It seems that the branding people focus most of their time and
> energy on processor implementations, rather than on families of
> processors.  So there isn't a clear answer from them on just what
> they'd like 0x20 to be tranlated to.  One did suggest:
> 
> family   : Dual-core Intel(r) Itanium(r) 2 processor 9000 series
> 
> But that rather seriously overflows the "char family[32]" buffer into
> which it would need to be copied, doesn't fit into the style of
> earlier family names as used by Linux and might be outdated if
> we are still using family 0x20 for processors with more than two
> cores.

And is a bit crass ... I mean we already plug it as a GenuineIntel in
the vendor field.  How about more plainly:

family    : Multi-core Itanium 2

I suppose this risks confusion with HP's Hondo package, though.  Maybe

family    : 9000 series Itanium 2

would do better?

> > Maybe we could put in a patch temporarily that calls it "Montecito",
> > then Intel can patch it to whatever the official marketing name is
> > upon release?
> 
> "Montecito" would be a poor choice.  Next processor in the series is
> "Montvale", and it will also have family 0x20.

I would hope that the family name would be decided before Montvale was
released ;-)

> 32 is good ... it even makes us more like arch/i386/kernel/cpu/proc.c
> which makes no attempt to interpret the number, just prints it in decimal.
> As a bonus, no patch is needed, nor will any future changes be needed
> as new family numbers are assigned!

Yes, I like this idea.  Being More Like i386 is always a good idea.

> The only remaining question is whether we should drop the translation
> of 0x7 to "Itanium" and 0x1f to "Itanium 2", and just unconditionally
> print the family as a decimal number.  This would make it all symetrical
> (but sadly requires strong evidence that there are no applications that
> depend on the old string values for the "family" field in /proc/cpuinfo).

We've always felt free to change these strings before.  Anyone relying
on them for anything more than display-to-the-user purposes is on a
losing streak.
