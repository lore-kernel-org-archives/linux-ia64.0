From: Frank Scheiner <frank.scheiner@web.de>
Date: Wed, 17 May 2023 18:38:53 +0000
Subject: Re: [crosspost] dropping support for ia64
Message-Id: <59a76177-8ed4-e71e-9b11-a673298b5b4b@web.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
In-Reply-To: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dear Ard, all,

First of all, I demand nothing of other people in this regard, you
included. Please notice there's no "but" attached.

I think I have a little first-hand knowledge about how much effort is
involved in keeping an interesting architecture from the past running,
to the least since when I thought it would be a cool idea to maintain
the retired sgi port of OpenBSD...

I have a few remarks below...

On 12.05.23 17:57, Ard Biesheuvel wrote:
> (cross posted to several ia64 related mailing list)
>
> Hello all,
>
> As the maintainer of the EFI subsystem in Linux, I am one of the
> people that have to deal with the impact that code refactoring for
> current platforms has on legacy use of such code, in this particular
> case, the use of shared EFI code in the Itanium Linux port.
>
> I am sending this message to gauge the remaining interest in ia64
> support across the OS/distro landscape, and whether people feel that
> the effort required to keep it alive is worth it or not.
>
> As a maintainer, I feel uncomfortable asking contributors to build
> test their changes for Itanium, and boot testing is infeasible for
> most, even if some people are volunteering access to infrastructure
> for this purpose. In general, hacking on kernels or bootloaders (which
> is where the EFI pieces live) is tricky using remote access.

That is all doable, at least all HP Integrity gear I am familiar with -
and which surely make up the majority of ia64 machines in hobbyist use -
are equipped with full remote control (console, reset, power, etc.). The
main problem at least in Germany is the insanity of our energy prices,
which were already too high before they skyrocketed in the recent past.
But you also wrote:

> The bottom line is that, while I know of at least 2 people (on cc)
> that test stuff on itanium, and package software for it, I don't think
> there are any actual users remaining, and so it is doubtful whether it
> is justified to ask people to spend time and effort on this.

While I get your argument, I also find it important to be able to
innovate without destroying the past. And with the already severly
limited choice of current architectures for the masses (x86, arm), it
becomes even more important to keep what we have or had in the past, to
not end in a "If all you have is a hammer, everything looks like a
nail." type of future.

> And for GRUB in particular (which is what triggered this message), it
> is unclear to me why any machines still running would not be better
> served by sticking with their current bootloader build, rather than
> upgrading to a new build with a refactored EFI layer where the best
> case scenario is that it boots the kernel in exactly the same way,
> while there is a substantial risk of regressions.

Sure, and every ia64 machine I have still network boots fine with elilo,
even the rx2800-i2. Though most people still have their root FS on disk,
where elilo might limit the choice of the bootstrap file system(s).

Plus elilo is gone from the Debian repositories, just like yaboot,
leaving grub2 as the only bootloader for ia64 there at the moment - if
I'm not mistaken. And I assume Adrian invested quite some time and work
to get grub2 usable as default boot loader for ia64 in Debian.

But apart from this - also from other posts - it is pretty obvious that
you seem to be absolutely determined to remove ia64 support from the
Linux ecosystem. So removing it from the bootloader is just a step stone
to removing ia64 support from the Linux kernel and a discussion about
the bootloader seems futile then.

> For the Linux kernel itself, the situation is quite similar. There is
> a non-zero effort involved in keeping things working, and if anyone
> still needs to run their programs on Itanium, it is not clear to me
> why that would require a recent version of the OS.
>
> So bottom line: I am proposing we drop support for Itanium across the
> board. Would anyone have any problems with that?

Of course I would have a problem with that. AFAIK GNU/Linux is the last
free OS for these machines. And I don't see those machines as museum
pieces yet, but as options for interested people, coming back to the
hammer and nail thing from above.

But I demand nothing of you. And to be honest I can't contribute at this
level to ia64, as I just don't have the required expertise for this type
of hacking.

Apart from that I'd like to thank all people involved in keeping those
interesting systems afloat for the good times I had and have on ia64 and
other interesting architectures and machines.

Cheers,
Frank

