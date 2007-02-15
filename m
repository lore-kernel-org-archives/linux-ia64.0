From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Thu, 15 Feb 2007 02:17:49 +0000
Subject: RE: Zero size /proc/vmcore on ia64
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086BF0@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070205015901.GA31446@verge.net.au>
In-Reply-To: <20070205015901.GA31446@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Magnus Damm
> Sent: 2007=C4=EA2=D4=C214=C8=D5 19:47
> To: Zou, Nanhai
> Cc: vgoyal@in.ibm.com; Horms; fastboot@lists.osdl.org;
> linux-ia64@vger.kernel.org
> Subject: Re: Zero size /proc/vmcore on ia64
>=20
> On 2/14/07, Zou, Nanhai <nanhai.zou@intel.com> wrote:
> > > From: Magnus Damm [mailto:magnus.damm@gmail.com]
> > > On 2/8/07, Vivek Goyal <vgoyal@in.ibm.com> wrote:
> > > > I think we should not remove this check because even to parse the i=
nfo
> > > > passed in ELF headers, you need to first read the ELF headers from =
crashed
> > > > kernel's memory. So if some programming error has passed wrong loca=
tion
> of
> > > > ELF headers (elfcoreheader=3D invalid location) then we might try r=
eading
> the
> > > > elf header from a non-existing physical page frame.
> > >
> > > Are you saying that the ELF header is located in the memory space of
> > > the first kernel?
> > >
> > > The way I read the code the ELF header is put into the reserved memory
> > > space for the secondary kernel. At least on ia64 that is true, and I
> > > think the same goes for i386.
> > >
> > > And the fact that the ELF header is put in to the secondary kernel
> > > brings me memory setup problems on ia64.
> > >
> > > Basically the ELF header is marked as EFI_UNUSABLE_MEMORY by the EFI
> > > mangling code in purgatory. The secondary kernel detects this while
> > > parsing the EFI tables and refuses to use/map the other memory present
> > > in the same 16M granule. And in my case the initramfs happens to be
> > > located in the same granule... boom! No good. =3D)
> > >
> > > So I'm wondering about the reason why we put the ELF header in the
> > > secondary kernel. Can't we just put it in the first kernel and be done
> > > with it? We still point it out using the kernel command line, don't
> > > we?
> >
> >   My first design is that putting data in second kernel is easy and saf=
er.
> We could put it in the first kernel if we provide an interface to reserve=
 this
> area at the time of kexec -p so that nobody will touch it even at the tim=
e of
> crash.
>=20
> Maybe that's a good idea. But that would make ia64 a special case and
> I'd like to avoid that as  long as possible.
>=20
> >   Align that buffer to 16M will solve the issue but that seems to be a =
waste
> of the useful memory?
>=20
> Right. We could require one granule per segment or something, but at
> load time we don't really know if the secondary kernel is using 16M or
> 64M granules. A safe bet would be to always use 64M, but that would
> require us to use quite a lot of memory for the secondary kernel.
>=20
> >   Another way is append this elf header to command line in purgatory, l=
ike
> we append the ummy efi function, maybe this is too hacky?
>=20
> Hm. I think that sounds a bit too hackish. =3D)
>=20
> What about the option of marking the ELF headers as EFI_LOADER_DATA
> and let the secondary kernel allocate new space and copy the data
> early during boot?
>=20
  Ah yes, I think vmcore.c has already done this, parse and store elf core =
header structure at kernel init, so mark that area as EFI_CONVENTIONAL_MEMO=
RY should be safe.=20
  This can be done by remove the reserved =3D 1 setting in crashdump-ia64.c

  Thanks
  Zou Nan hai=20
> Thanks!
>=20
> / magnus
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
