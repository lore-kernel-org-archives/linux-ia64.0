From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Fri, 27 Oct 2006 01:40:59 +0000
Subject: RE: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086AFE@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: Mel Gorman [mailto:mel@csn.ul.ie]
> Sent: 2006=C4=EA10=D4=C226=C8=D5 21:27
> To: Horms
> Cc: linux-ia64@vger.kernel.org; Linus Torvalds; Bob Picco; Andrew Morton;=
 Dave
> Hansen; Andy Whitcroft; Andi Kleen; Benjamin Herrenschmidt; Paul Mackerra=
s;
> Keith Mannthey; Luck, Tony; KAMEZAWA Hiroyuki; Yasunori Goto; Zou, Nanhai;
> Khalid Aziz
> Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
>=20
> From mel@csn.ul.ie Thu Oct 26 14:10:39 2006
> Date: Thu, 26 Oct 2006 14:10:39 +0100 (IST)
> From: Mel Gorman <mel@csn.ul.ie>
> To: Andy Whitcroft <apw@shadowen.org>
> Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
>=20
> On Thu, 26 Oct 2006, Horms wrote:
>=20
> > Hi,
> >
> > After doing a bit of research it seems that ia64 kdump is broken
> > by 05e0caad3b7bd0d0fbeff980bca22f186241a501, which appeared between
> > 2.6.18 and 2.6.19-rc3. I can be more specific about the version if
> > need be, but here is the commit log from Linus' tree.
> >
>=20
> Ok, Andy Whitcroft and I both took a few kicks at this problem to see what
> the story was. My current understanding (given to me by Andy) with kdump =
is
> this
>=20
> 1. Normal kernel boots and leaves a kdump hole in memory somewhere
> 2. In the kdump hole, a crash dump kernel is loaded
> 3. Things run happily for a while until something goes wrong. kexec is
>     called on the kernel image in the kdump hole
> 4. kdump kernel starts and creates an image
>=20
> Grand so far.
>=20
> Now, with arch-independent zone-sizing, an architecture states where "rea=
l"
> memory is and memmap is initialised in those ranges.
>=20
> The maps of the two kernels look like this
>=20
> Normal Kernel
> > early_node_map[7] active PFN ranges
> >    0:     1025 ->     4096
> >    0:     4567 ->    16384
> >    0:    32768 ->   125911
> >    0:   126514 ->   127540
> >    0:   127541 ->   128557
> >    0:   128576 ->   130688
> >    0:   130984 ->   130998
>=20
> Crash kernel
> > early_node_map[7] active PFN ranges
> >    0:    16855 ->    16856
> >    0:    16857 ->    32096
> >    0:    32752 ->    32753
> >    0:    32754 ->    32755
> >    0:    32756 ->    32757
> >    0:    32758 ->    32761
> >    0:    32762 ->    32768
>=20
> So, there is clearly a hole there between 16384 -> 32768 for the kdump ho=
le
> in the normal kernel. I expect the kernel image and __init sections are
> located at PFN 16384.
>=20
> The problem is that the crash kernel is reporting that memory starts at
> 16855, a gap of 471 page frames! memmap will not be initialised here beca=
use
> it "doesn't exist" even though the memmap will be allocated because of
> MAX_ORDER-alignment issues
>=20
> The first fault looks like this
>=20
> > page:a0007ffffff23598 flags:0x0000000000000000 mapping:0000000000000000
> > mapcount:1 count:0
>=20
> Based on the value of virtual mem_map, that is at PFN 16629 or about 245
> page frames into the kernel image. In the stack trace, you see
> free_initmem() is being called. i.e. the __init section appears in a memo=
ry
> hole where memmap was never initialised.
>=20
> I haven't looked at how kdump works yet, but you are either supplying a f=
ake
> EFI map that omits the kernel image or else you only read a portion of the
> EFI when booting a crash kernel and start reading after the kernel image
> ends. If the EFI covers the kernel image, you'll see an entry like this in
> the early_node_map
>=20
> 0: 16384 -> 16855
>=20
> and that bad_page() will disappear.
>=20
> We'll start kicking at the kdump patches now, but maybe a kdump expert can
> tell offhand why the crash kernel's EFI map does not cover the kernel ima=
ge.
>=20

EFI memmap is changed in purgatory code.
I mark old EFI memmap entry with attribute EFI_LOADER_DATA as EFI_CONVENTIO=
NAL_MEMORY, then mark the range of crash kernel image as EFI_LOADER_DATA. D=
uring this some EFI memmap range may be split, but the entire layout is not=
 changed.

I am building 2.6.19-rc3 to see if I can reproduce the issue.

Thanks
Zou Nan hai
