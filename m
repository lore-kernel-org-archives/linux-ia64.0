From: Mike Rapoport <rppt@kernel.org>
Date: Wed, 28 Oct 2020 18:57:41 +0000
Subject: Re: [PATCH 11/13] m68k/mm: make node data and node setup depend on CONFIG_DISCONTIGMEM
Message-Id: <20201028185741.GI1428094@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201027112955.14157-1-rppt@kernel.org>
 <20201027112955.14157-12-rppt@kernel.org>
 <CAMuHMdU4r4CJ1kBu7gx1jkputjDn2S8Lqkj7RPfa3XUnM1QOFg@mail.gmail.com>
 <20201028111631.GF1428094@kernel.org>
 <fd55643a-a17b-5a23-4c77-9e832c1e5128@gmail.com>
In-Reply-To: <fd55643a-a17b-5a23-4c77-9e832c1e5128@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Michael Schmitz <schmitzmic@gmail.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Greg Ungerer <gerg@linux-m68k.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Jonathan Corbet <corbet@lwn.net>, Matt Turner <mattst88@gmail.com>, Meelis Roos <mroos@linux.ee>, Mike Rapoport <rppt@linux.ibm.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Will Deacon <will@kernel.org>, alpha <linux-alpha@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux MM <linux-mm@kvack.org>, arcml <linux-snps-arc@lists.infradead.org>

On Thu, Oct 29, 2020 at 07:14:38AM +1300, Michael Schmitz wrote:
> Hi Mike,
>=20
> On 29/10/20 12:16 AM, Mike Rapoport wrote:
> > Hi Geert,
> >=20
> > On Wed, Oct 28, 2020 at 10:25:49AM +0100, Geert Uytterhoeven wrote:
> > > Hi Mike,
> > >=20
> > > On Tue, Oct 27, 2020 at 12:31 PM Mike Rapoport <rppt@kernel.org> wrot=
e:
> > > > From: Mike Rapoport <rppt@linux.ibm.com>
> > > >=20
> > > > The pg_data_t node structures and their initialization currently de=
pends on
> > > > !CONFIG_SINGLE_MEMORY_CHUNK. Since they are required only for DISCO=
NTIGMEM
> > > > make this dependency explicit and replace usage of
> > > > CONFIG_SINGLE_MEMORY_CHUNK with CONFIG_DISCONTIGMEM where appropria=
te.
> > > >=20
> > > > The CONFIG_SINGLE_MEMORY_CHUNK was implicitly disabled on the ColdF=
ire MMU
> > > > variant, although it always presumed a single memory bank. As there=
 is no
> > > > actual need for DISCONTIGMEM in this case, make sure that ColdFire =
MMU
> > > > systems set CONFIG_SINGLE_MEMORY_CHUNK to 'y'.
> > > >=20
> > > > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > > Thanks for your patch!
> > >=20
> > > > ---
> > > >   arch/m68k/Kconfig.cpu           | 6 +++---
> > > >   arch/m68k/include/asm/page_mm.h | 2 +-
> > > >   arch/m68k/mm/init.c             | 4 ++--
> > > >   3 files changed, 6 insertions(+), 6 deletions(-)
> > > Is there any specific reason you didn't convert the checks for
> > > CONFIG_SINGLE_MEMORY_CHUNK in arch/m68k/kernel/setup_mm.c
> > In arch/m68k/kernel/setup_mm.c the CONFIG_SINGLE_MEMORY_CHUNK is needed
> > for the case when a system has two banks, the kernel is loaded into the
> > second bank and so the first bank cannot be used as normal memory. It
> > does not matter what memory model will be used in this case.
>=20
>=20
> That case used to be detected just fine at run time (by dint of the second
> memory chunk having an address below the first; the chunk the kernel resi=
des
> in is always listed first), even without using CONFIG_SINGLE_MEMORY_CHUNK.
=20
Right, CONFIG_SINGLE_MEMORY_CHUNK in arch/m68k/kernel/setup_mm.c is used
to force using a single bank of memory regardless of run time detection.=20

> Unless you changed that behaviour (and I see nothing in your patch that
> would indicate that), this is still true.
>=20
> Converting the check as Geert suggested, without also adding a test for
> out-of-order memory bank addresses, would implicitly treat DISCONTIGMEM a=
s=A0
> SINGLE_MEMORY_CHUNK, regardless of bank ordering. I don't think that is w=
hat
> we really want?

It is in a way the case now when !SINGLE_MEMORY_CHUNK =3D DISCONTIGMEM.
So forcing SIGNLE_MEMORY_CHUNK at compile time would also mean forcing
FLATMEM.

After these changes I think SINGLE_MEMORY_CHUNK is not needed at all.

> Cheers,
>=20
> =A0=A0=A0 Michael
>=20
>=20
> >=20
> > > and arch/m68k/include/asm/virtconvert.h?
> > I remember I had build errors and troubles with include file
> > dependencies if I changed it there, but I might be mistaken. I'll
> > recheck again.
> >=20
> > > Gr{oetje,eeting}s,
> > >=20
> > >                          Geert
> > >=20
> > > --=20
> > > Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linu=
x-m68k.org
> > >=20
> > > In personal conversations with technical people, I call myself a hack=
er. But
> > > when I'm talking to journalists I just say "programmer" or something =
like that.
> > >                                  -- Linus Torvalds

--=20
Sincerely yours,
Mike.
