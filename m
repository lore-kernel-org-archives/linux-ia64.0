From: Russell King - ARM Linux admin <linux@armlinux.org.uk>
Date: Sat, 19 Jan 2019 14:28:52 +0000
Subject: Re: [PATCH v2 29/29] y2038: add 64-bit time_t syscalls to all 32-bit architectures
Message-Id: <20190119142852.cntdihah4mpa3lgx@e5254000004ec.dyn.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190118161835.2259170-1-arnd@arndb.de>
 <20190118161835.2259170-30-arnd@arndb.de>
 <CALCETrXqM5mhvwreN5y-9K99h1j9rs9MAVK-cNLC54s1fdHA6w@mail.gmail.com>
 <CAK8P3a0V+xboaGAF2nqrYtpjXXA7y0LcvCKi4ngLTus1D_XZBA@mail.gmail.com>
 <CALCETrWPj6dHEyo=AELoVjXGsiwuSpRp17x3CEWBHvp7i3cy+Q@mail.gmail.com>
In-Reply-To: <CALCETrWPj6dHEyo=AELoVjXGsiwuSpRp17x3CEWBHvp7i3cy+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Lutomirski <luto@kernel.org>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Will Deacon <will.deacon@arm.com>, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Network Development <netdev@vger.kernel.org>, Deepa Dinamani <deepa.kernel@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, y2038 Mailman List <y2038@lists.linaro.org>, Michael Ellerman <mpe@ellerman.id.au>, Helge Deller <deller@gmx.de>, X86 ML <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <catalin.marinas@arm.com>, Firoz Khan <firoz.khan@linaro.org>, Matt Turner <mattst88@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arnd>

On Fri, Jan 18, 2019 at 11:53:25AM -0800, Andy Lutomirski wrote:
> On Fri, Jan 18, 2019 at 11:33 AM Arnd Bergmann <arnd@arndb.de> wrote:
> >
> > On Fri, Jan 18, 2019 at 7:50 PM Andy Lutomirski <luto@kernel.org> wrote:
> > > On Fri, Jan 18, 2019 at 8:25 AM Arnd Bergmann <arnd@arndb.de> wrote:
> > > > - Once we get to 512, we clash with the x32 numbers (unless
> > > >   we remove x32 support first), and probably have to skip
> > > >   a few more. I also considered using the 512..547 space
> > > >   for 32-bit-only calls (which never clash with x32), but
> > > >   that also seems to add a bit of complexity.
> > >
> > > I have a patch that I'll send soon to make x32 use its own table.  As
> > > far as I'm concerned, 547 is *it*.  548 is just a normal number and is
> > > not special.  But let's please not reuse 512..547 for other purposes
> > > on x86 variants -- that way lies even more confusion, IMO.
> >
> > Fair enough, the space for those numbers is cheap enough here.
> > I take it you mean we also should not reuse that number space if
> > we were to decide to remove x32 soon, but you are not worried
> > about clashing with arch/alpha when everything else uses consistent
> > numbers?
> >
> 
> I think we have two issues if we reuse those numbers for new syscalls.
> First, I'd really like to see new syscalls be numbered consistently
> everywhere, or at least on all x86 variants, and we can't on x32
> because they mean something else.  Perhaps more importantly, due to
> what is arguably a rather severe bug, issuing a native x86_64 syscall
> (x32 bit clear) with nr in the range 512..547 does *not* return
> -ENOSYS on a kernel with x32 enabled.  Instead it does something that
> is somewhat arbitrary.  With my patch applied, it will return -ENOSYS,
> but old kernels will still exist, and this will break syscall probing.
> 
> Can we perhaps just start the consistent numbers above 547 or maybe
> block out 512..547 in the new regime?

I don't think you gain much with that kind of scheme - it won't take
very long before an architecture misses having a syscall added, and
then someone else adds their own.  Been there with ARM - I was keeping
the syscall table in the same order as x86 for new syscalls, but now
that others have been adding syscalls to the table since I converted
ARM to the tabular form, that's now gone out the window.

So, I think it's completely pointless to do what you're suggesting.
We'll just end up with a big hole in the middle of the syscall table
and then revert back to random numbering of syscalls thereafter again.

-- 
RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
