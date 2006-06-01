From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Thu, 01 Jun 2006 03:06:16 +0000
Subject: Re: Montecito processor family
Message-Id: <200606010306.k5136Jix804158@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42ADD890.1010406@free.fr>
In-Reply-To: <42ADD890.1010406@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> Digging up this from the distant past (November, 2005): 
> 
> > > I see that nothing has happend to Montecito's family name
> > > in both Linus' and Tony's tree since then.
> > > 
> > > Is adding 'Itanium 2' for case 0x20 enough or do we need
> > > something different?
> 
> Printing "Itanium 2" hides information since that is the
> same string as we use for family 0x1f.  So this would make
> it hard/impossible for a script reading /proc/cpuinfo to tell
> whether the cpu was McKinley/Madison or Montecito.

Why not have "model name" with the text name, like on ia32?

vendor_id       : GenuineIntel
cpu family      : 15
model           : 4
model name      : Intel(R) Pentium(R) 4 CPU 2.80GHz
stepping        : 1

> > > Intel people may want to decide what it should be, according to
> > > their marketing/branding plan ;)
> 
> It seems that the branding people focus most of their time and
> energy on processor implementations, rather than on families of
> processors.  So there isn't a clear answer from them on just what
> they'd like 0x20 to be tranlated to.  One did suggest:
> 
> family   : Dual-core Intel(r) Itanium(r) 2 processor 9000 series

That's almost as bad as "Intel(R) Pentium(R) 4 CPU 2.80GHz".

I like the "Pentium III (Coppermine)" style, based on family
and model.  "Itanium 2 (Madison)" and "Itanium 2 (Montecito)" would
be consistent with that style.  

> > Maybe we could put in a patch temporarily that calls it "Montecito",
> > then Intel can patch it to whatever the official marketing name is
> > upon release?
> 
> "Montecito" would be a poor choice.  Next processor in the series is
> "Montvale", and it will also have family 0x20.

That's why a combination of family and model is needed.

> > IIRC the field once was "McKinley" for Itanium2 but later replaced with
> > "Itanium 2".  So this sounds ok.  But probably as no real application
> > depends on or relies on the field, I think we can display '32' as it
> > is until the 'official' name is given.
> 
> 32 is good ... it even makes us more like arch/i386/kernel/cpu/proc.c
> which makes no attempt to interpret the number, just prints it in decimal.
> As a bonus, no patch is needed, nor will any future changes be needed
> as new family numbers are assigned!

It would be nice to have a "model name" text description,
for people that don't know the meaning of 32.  There are
people that need to use the right flavor of CPU that know
the English name.  It's easier to have the code print the
text name than teach them the cryptic numbers.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
