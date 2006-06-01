From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 01 Jun 2006 00:03:27 +0000
Subject: RE: Montecito processor family
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F069FFB56@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42ADD890.1010406@free.fr>
In-Reply-To: <42ADD890.1010406@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Digging up this from the distant past (November, 2005): 

> > I see that nothing has happend to Montecito's family name
> > in both Linus' and Tony's tree since then.
> > 
> > Is adding 'Itanium 2' for case 0x20 enough or do we need
> > something different?

Printing "Itanium 2" hides information since that is the
same string as we use for family 0x1f.  So this would make
it hard/impossible for a script reading /proc/cpuinfo to tell
whether the cpu was McKinley/Madison or Montecito.

> > Intel people may want to decide what it should be, according to
> > their marketing/branding plan ;)

It seems that the branding people focus most of their time and
energy on processor implementations, rather than on families of
processors.  So there isn't a clear answer from them on just what
they'd like 0x20 to be tranlated to.  One did suggest:

family   : Dual-core Intel(r) Itanium(r) 2 processor 9000 series

But that rather seriously overflows the "char family[32]" buffer into
which it would need to be copied, doesn't fit into the style of
earlier family names as used by Linux and might be outdated if
we are still using family 0x20 for processors with more than two
cores.

> I'm sure they're having trouble getting that patch through Intel legal ;-)
Marketing is a much tougher sell than legal :-)
 
> Maybe we could put in a patch temporarily that calls it "Montecito",
> then Intel can patch it to whatever the official marketing name is
> upon release?

"Montecito" would be a poor choice.  Next processor in the series is
"Montvale", and it will also have family 0x20.

> IIRC the field once was "McKinley" for Itanium2 but later replaced with
> "Itanium 2".  So this sounds ok.  But probably as no real application
> depends on or relies on the field, I think we can display '32' as it
> is until the 'official' name is given.

32 is good ... it even makes us more like arch/i386/kernel/cpu/proc.c
which makes no attempt to interpret the number, just prints it in decimal.
As a bonus, no patch is needed, nor will any future changes be needed
as new family numbers are assigned!

The only remaining question is whether we should drop the translation
of 0x7 to "Itanium" and 0x1f to "Itanium 2", and just unconditionally
print the family as a decimal number.  This would make it all symetrical
(but sadly requires strong evidence that there are no applications that
depend on the old string values for the "family" field in /proc/cpuinfo).

-Tony
