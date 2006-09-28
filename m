From: "Magnus Damm" <magnus.damm@gmail.com>
Date: Thu, 28 Sep 2006 12:33:11 +0000
Subject: Re: [Xen-ia64-devel] Re: ia64 kexec: xen -> linux
Message-Id: <aec7e5c30609280533i66f6d34ct9fd28ac82e06e350@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200609271152.12393.Tristan.Gingold@bull.net>
In-Reply-To: <200609271152.12393.Tristan.Gingold@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On 9/27/06, Tristan Gingold <Tristan.Gingold@bull.net> wrote:
> Le Mercredi 27 Septembre 2006 11:36, Magnus Damm a =E9crit :
> > On 9/15/06, Horms <horms@verge.net.au> wrote:
> > > Hi,
> > >
> > > as some of you may be aware I am working on porting kexec
> > > to xen/ia64. I have made a reasoble ammount of progress to this end.
> > > I'll try and get a new patch set on xen-devel some time next week.
> > > However I have a problem that I need some ideas on how to solve.
> > >
> > > At the moment when kexecing from xen to linux the boot halts on a call
> > > to efi_gettimeofday(), or more specifically efi.get_time. I'm assuming
> > > that this is more or less the first efi runtime call that is made, and
> > > that it is halting because of a discrepancy in the virtual mapping set
> > > up by efi.set_virtual_address_map().
> > >
> > > The problem as I see it is that linux uses a page_offset that covers =
the
> > > most significant 3 bits, wherase xen uses the first 4. The unfortunate
> > > thing is that efi.set_virtual_address_map() can only be called once,
> > > and I don't think its possible to change the mappings at all once
> > > its been called.
> > >
> > > One idea that I had was to make sure that the efi calls are always ma=
de
> > > in real mode, and never call efi.set_virtual_address_map() at all - e=
fi
> > > calls have to be made using virtual addressing after
> > > efi.set_virtual_address_map() is called. But can this work?
> > >
> > > Another idea from my colleague Magnus was to map the efi runtime calls
> > > into some area of memory that is agreed upon by both Linux and Xen (a=
nd
> > > any other kexec-able OS/hypervisor). This seems to be tedious at best.
> >
> > To clarify this a bit, my plan was to extend the bootloader to provide
> > some kind resident efi filter code. This code should act as a filter
> > for all efi run time calls including the dreaded now use-once
> > set_virtual_address_map() function. The most important task for this
> > code would be to support an unlimited number of
> > set_virtual_address_map() calls. I suspect this can be done by always
> > calling the efi functions from real mode. This technique does however
> > require switching back and forth to real mode, and I'm not sure how
> > well that will work out with NMI:s and data that crosses page
> > boundaries.
> >
> > A first step would probably be to try to convert Linux into calling
> > efi runtime functions from real mode. If that works well then the code
> > can be broken out, made resident and placed into the bootloader.
>
> Linux and xen call efi in real mode if set_virtual_address_map fails.
> You may add an option in both xen and linux to force calling efi in real =
mode.
> This should be really simple and you will be able to make progress.

Oh, is that so? I have not looked at the code yet, only discussed this
issue with Horms so far. But that's good news. Thanks for the
suggestion!

/ magnus
