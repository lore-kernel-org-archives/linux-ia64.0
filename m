From: Ard Biesheuvel <ardb@kernel.org>
Date: Wed, 15 Feb 2023 15:40:30 +0000
Subject: Re: [RFC PATCH] MAINTAINERS: Mark Itanium/IA64 as 'dead'
Message-Id: <CAMj1kXEnoghSNpQFucmSCEhG3s_nyBCm+btgLHzOTiU56=XPfQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230128122904.1345120-1-ardb@kernel.org> <20230215151547.GA3766362@roeck-us.net>
In-Reply-To: <20230215151547.GA3766362@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guenter Roeck <linux@roeck-us.net>
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, Tony Luck <tony.luck@intel.com>, Jessica Clarke <jrtc27@jrtc27.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org

On Wed, 15 Feb 2023 at 16:15, Guenter Roeck <linux@roeck-us.net> wrote:
>
> On Sat, Jan 28, 2023 at 01:29:04PM +0100, Ard Biesheuvel wrote:
> > Create a new status 'dead' which conveys that a subsystem is
> > unmaintained and scheduled for removal, and developers are free to
> > behave as if it's already gone. Also, automated build tests should
> > ignore such subsystems, or at least notify only those who are known to
> > have an interest in the subsystem in particular.
> >
> > Given that Itanium/IA64 has no maintainer, is no longer supported in
> > QEMU (for boot testing under emulation) and does not seem to have a user
> > base beyond a couple of machines used by distros to churn out packages,
> > let's mark it as dead. This shall mean that any treewide changes (such
> > as changes to the EFI subsystem, which I maintain) can be made even if
> > they might cause build or boot time regressions on IA64 machines. Also,
> > mark the port as scheduled for removal after the next LTS release.
> >
>
> Since this just came up, I very much prefer complete removal. I don't
> see the point of keeping dead code in the tree. That is still hidden
> maintenance effort.
>

Can I take this as an ack on

https://lore.kernel.org/linux-kernel/20230215100008.2565237-1-ardb@kernel.org/

?

> If this proliferates, we'll end up having to parse the MAINTAINERS file
> for code marked "Dead" to ensure that we don't accidentally send e-mails
> to the wrong people, or we risk getting complaints about sending reports
> for such code. That puts extra burden on maintainers of automated test
> beds, which I think is not really appropriate. If the code is dead,
> remove it, period.
>
> For my part, I'll drop my test bed support immediately after this patch
> made it in, following the guidance above.
>

Thanks for the insight. I think we should take the immediate removal route.
