From: Tristan Gingold <Tristan.Gingold@bull.net>
Date: Thu, 28 Sep 2006 12:47:37 +0000
Subject: Re: [Xen-ia64-devel] Re: ia64 kexec: xen -> linux
Message-Id: <200609281447.37960.Tristan.Gingold@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200609271152.12393.Tristan.Gingold@bull.net>
In-Reply-To: <200609271152.12393.Tristan.Gingold@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Le Jeudi 28 Septembre 2006 14:34, Magnus Damm a =E9crit :
> On 9/28/06, Tristan Gingold <Tristan.Gingold@bull.net> wrote:
> > Le Jeudi 28 Septembre 2006 03:27, Horms a =E9crit :
> > > On Wed, Sep 27, 2006 at 11:52:12AM +0200, Tristan Gingold wrote:
> > > > Linux and xen call efi in real mode if set_virtual_address_map fail=
s.
> > > > You may add an option in both xen and linux to force calling efi in
> > > > real mode. This should be really simple and you will be able to make
> > > > progress.
> > >
> > > Great, I will test this out and see how it goes.
> > >
> > > > The only possible drawback is performance.
> > >
> > > What kind of performance issues would you expect?
> >
> > Making EFI calls in physical mode is slower: Linux must switch from and
> > to virtual mode.
> >
> > However EFI calls are very unfrequent so the impact should be almost nu=
l.
>
> This makes me wonder - is it really worth having two code paths in that
> case?
According to linux/arch/ia64/kernel/efi.c, the code to switch efi to virtua=
l=20
mode was added later.  I don't know why this was added.  Maybe the answer i=
s=20
in the web?

Tristan.
