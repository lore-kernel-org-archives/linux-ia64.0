From: Ard Biesheuvel <ardb@kernel.org>
Date: Mon, 22 May 2023 07:46:57 +0000
Subject: Re: [crosspost] dropping support for ia64
Message-Id: <CAMj1kXFWCo4kqkGeYDqY9JJ3bTesJefKTPFhnnszWHbbD4jXwQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
In-Reply-To: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 22 May 2023 at 09:39, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
>
> On Mon, May 22, 2023 at 09:08:35AM +0200, Ard Biesheuvel wrote:
> > (cc Greg as stable maintainer)
> >
> > On Sat, 20 May 2023 at 21:23, John Paul Adrian Glaubitz
> > <glaubitz@physik.fu-berlin.de> wrote:
> > >
> > ...
> > >
> > > I have been thinking about this discussion for a while now and my suggestion
> > > would be to drop ia64 support from the kernel, GRUB and gcc/binutils/glibc in
> > > this order:
> > >
> > > - Kernel: After the next LTS release
> > > - GRUB: After the 2.12 release
> > > - gcc/binutils/glibc: After support was dropped from the kernel
> > >
> > > This way anyone still using ia64 will be able to use it with a supported codebase
> > > for an extended time and upstream projects have target releases for which they
> > > can plan the removal.
> > >
> >
> > Yeah, I think this is reasonable. Having a clear agreement on where
> > the support ends helps both the remaining users and the developers
> > eager to move on.
> >
> > My only question is how we would land fixes for ia64 into this Linux
> > LTS release if there is no upstream any longer to draw from.
> >
> > Greg, could you comment on this?
>
> That would imply that people actually used that arch and code, so why
> would it have been removed from Linus's tree?
>

As far as we have been able to establish, the only people that use
this arch and code are people that would hate to see it go, but don't
actually use it for anything other than checking whether it still
boots, and don't have the skills or bandwidth to step up and maintain
it upstream.

> And there's nothing "special" about LTS releases for features like this,
> just drop the code when no one is using it and all is good.
>

Fair enough.
