From: Ard Biesheuvel <ardb@kernel.org>
Date: Fri, 12 May 2023 14:45:55 +0000
Subject: Re: [RFC PATCH 0/5] Retire IA64/Itanium support
Message-Id: <CAMj1kXGXCFFQQObtkGje=Hym0GuEgR3h85MX8d1_hBb=b3Fxdg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org> <87y1nvng1s.fsf@mid.deneb.enyo.de>
In-Reply-To: <87y1nvng1s.fsf@mid.deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Florian Weimer <fw@deneb.enyo.de>
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, Tony Luck <tony.luck@intel.com>, Jessica Clarke <jrtc27@jrtc27.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org

On Fri, 17 Mar 2023 at 23:56, Florian Weimer <fw@deneb.enyo.de> wrote:
>
> * Ard Biesheuvel:
>
> > The IA64 port of Linux has no maintainer, and according to a report from
> > its only remaining user [0], it has been broken for a month and nobody
> > cares.
> >
> > Given that keeping a complex but unused architecture alive uses up
> > valuable developer bandwidth, let's just get rid of it.
> >
> > This supersedes my patch proposing to mark it as 'dead', which received
> > no replies from anyone that wants to keep it alive. [1]
>
> Is this still going ahead?
>
> In userspace, ia64 is of course full of special cases, too, so many of
> us really want to see it gone, but we can't really start the removal
> process while there is still kernel support.

I brought this up again [0] in the context of GRUB (which has similar
issues related to EFI the the kernel has) and Adrian suggested to
raise this discussion more widely, perhaps on the distributions
mailing list, among other places.

Do you have any recommendations for a venue where we might find the
right mix of people who can drive this to a conclusion one way or the
other?

Thanks,


[0] https://lists.gnu.org/archive/html/grub-devel/2023-05/msg00068.html
