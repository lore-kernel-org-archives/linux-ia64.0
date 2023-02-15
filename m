From: Ard Biesheuvel <ardb@kernel.org>
Date: Wed, 15 Feb 2023 16:59:59 +0000
Subject: Re: [RFC PATCH 0/5] Retire IA64/Itanium support
Message-Id: <CAMj1kXFmZYmrZB7QyLCu3rpkChat=PVqPHsOi+HuWRj-FZ2S-g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org> <mhng-37f3f56f-70a4-4800-8685-e9a4c5922ce5@palmer-ri-x1c9>
In-Reply-To: <mhng-37f3f56f-70a4-4800-8685-e9a4c5922ce5@palmer-ri-x1c9>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Palmer Dabbelt <palmer@dabbelt.com>
Cc: linux-kernel@vger.kernel.org, corbet@lwn.net, Arnd Bergmann <arnd@arndb.de>, tony.luck@intel.com, jrtc27@jrtc27.com, glaubitz@physik.fu-berlin.de, willy@infradead.org, Marc Zyngier <maz@kernel.org>, linux@roeck-us.net, Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org

On Wed, 15 Feb 2023 at 17:50, Palmer Dabbelt <palmer@dabbelt.com> wrote:
>
> On Wed, 15 Feb 2023 02:00:03 PST (-0800), ardb@kernel.org wrote:
> > The IA64 port of Linux has no maintainer, and according to a report from
> > its only remaining user [0], it has been broken for a month and nobody
> > cares.
> >
> > Given that keeping a complex but unused architecture alive uses up
> > valuable developer bandwidth, let's just get rid of it.
> >
> > This supersedes my patch proposing to mark it as 'dead', which received
> > no replies from anyone that wants to keep it alive. [1]
> >
> > [0] https://www.spinics.net/lists/linux-ia64/msg21926.html
> > [1] https://lore.kernel.org/all/20230128122904.1345120-1-ardb@kernel.org/
> >
> > Cc: Jonathan Corbet <corbet@lwn.net>
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: Tony Luck <tony.luck@intel.com>
> > Cc: Jessica Clarke <jrtc27@jrtc27.com>
> > Cc: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
> > Cc: Matthew Wilcox <willy@infradead.org>
> > Cc: Marc Zyngier <maz@kernel.org>
> > Cc: Guenter Roeck <linux@roeck-us.net>
> > Cc: Linus Torvalds <torvalds@linux-foundation.org>
> > Cc: linux-ia64@vger.kernel.org
> >
> > Ard Biesheuvel (5):
> >   arch: Remove Itanium (IA-64) architecture
> >   kernel: Drop IA64 support from sig_fault handlers
> >   Documentation: Drop IA64 from feature descriptions
> >   lib/raid6: Drop IA64 support
> >   Documentation: Drop or replace remaining mentions of IA64
>
> Not sure if I'm missing it in the diff, but it looks like there's also a
> bunch of "#ifdef __ia64__" and "#ifdef __IA64__" type code spread
> throughout the kernel.  I didn't look at the actual diff, but it's in
> files that aren't showing up in the diffstat.
>

Thanks for taking a look. It seems I indeed missed a couple.

> Just "git grep -i __ia64__" lists a bunch.  I didn't look at all of
> them, but at least spot checking include/acpi/actypes.h looks like it's
> a real Itanium workaround.  If the arch goes, it's probbaly worth
> removing those too?
>

The ACPI code is synced with another project, so I didn't touch it.
Same goes for some other header files where IA-64 is referenced, e.g.,
in the PE/COFF header stuff.

> There's also some mentions of "Itanium" in Documentation outside that
> don't look like they got caught here.  Not sure if they'd be worth
> getting rid of, though as they could still be useful examples.  The
> blurb in Documentation/memory-barriers.txt looks pretty port-specific,
> though.
>

Yeah, I don't think it is necessary to rewrite history soviet-style,
so some remaining references are fine IMHO.
