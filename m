From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Wed, 14 Feb 2007 09:57:58 +0000
Subject: RE: Zero size /proc/vmcore on ia64
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086BEC@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070205015901.GA31446@verge.net.au>
In-Reply-To: <20070205015901.GA31446@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Magnus Damm [mailto:magnus.damm@gmail.com]
> Sent: 2007=C4=EA2=D4=C214=C8=D5 16:28
> To: vgoyal@in.ibm.com
> Cc: Horms; Zou, Nanhai; fastboot@lists.osdl.org; linux-ia64@vger.kernel.o=
rg
> Subject: Re: Zero size /proc/vmcore on ia64
>=20
> Vivek, everyone,
>=20
> On 2/8/07, Vivek Goyal <vgoyal@in.ibm.com> wrote:
> > I think we should not remove this check because even to parse the info
> > passed in ELF headers, you need to first read the ELF headers from cras=
hed
> > kernel's memory. So if some programming error has passed wrong location=
 of
> > ELF headers (elfcoreheader=3D invalid location) then we might try readi=
ng the
> > elf header from a non-existing physical page frame.
>=20
> Are you saying that the ELF header is located in the memory space of
> the first kernel?
>=20
> The way I read the code the ELF header is put into the reserved memory
> space for the secondary kernel. At least on ia64 that is true, and I
> think the same goes for i386.
>=20
> And the fact that the ELF header is put in to the secondary kernel
> brings me memory setup problems on ia64.
>=20
> Basically the ELF header is marked as EFI_UNUSABLE_MEMORY by the EFI
> mangling code in purgatory. The secondary kernel detects this while
> parsing the EFI tables and refuses to use/map the other memory present
> in the same 16M granule. And in my case the initramfs happens to be
> located in the same granule... boom! No good. =3D)
>=20
> So I'm wondering about the reason why we put the ELF header in the
> secondary kernel. Can't we just put it in the first kernel and be done
> with it? We still point it out using the kernel command line, don't
> we?

  My first design is that putting data in second kernel is easy and safer. =
We could put it in the first kernel if we provide an interface to reserve t=
his area at the time of kexec -p so that nobody will touch it even at the t=
ime of crash.

  Align that buffer to 16M will solve the issue but that seems to be a wast=
e of the useful memory?
  Another way is append this elf header to command line in purgatory, like =
we append the ummy efi function, maybe this is too hacky?
 =20
  Thanks
  Zou Nan hai
>=20
> Thanks,
>=20
> / magnus
