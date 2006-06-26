From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Mon, 26 Jun 2006 08:49:04 +0000
Subject: RE: [Fastboot] Ia64 kdump patch
Message-Id: <08B1877B2880CE42811294894F33AD5C053B58@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060608083516.GH28607@verge.net.au>
In-Reply-To: <20060608083516.GH28607@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org



> -----Original Message-----
> From: Horms [mailto:horms@verge.net.au]
> Sent: 2006=C4=EA6=D4=C226=C8=D5 16:37
> To: Zou, Nanhai
> Cc: Linux-IA64; khalid_aziz@hp.com; fastboot@lists.osdl.org
> Subject: Re: [Fastboot] Ia64 kdump patch
>=20
> On Mon, Jun 26, 2006 at 04:10:44PM +0800, Zou, Nanhai wrote:
> >   The list is a bit wrong.., I notice that we don't need to dump
> >   unwind segment to core file for stack unwind to work... I am working
> >   on full register dumping and fixing the stack unwind issue.
>=20
> Awsome, if you have anything that needs testing I am more than
> happy to help. I am a bit confused about which registers are
> saved and which aren't in the current code, but I figure that mainly
> relates to the code being incomplete.
>=20
> >  The PCI device shutdown code was to un-master all the PCI devices so t=
hat
> no DMA transaction will be issued by Device. However I think maybe we can=
 remove
> this code because the new kernel memory space is invisible to first kerne=
l.
>=20
> Ok, that makes a lot of sense. I was really puzzling over
> why ia64 does this but x86_32 doesn't. I also suspect it
> can be safely removed. Would you like me to test that out
> and send a patch if it works?
>=20
  Please.
> > There is another problem that I call irq->end for each devices, it is
> > not safe to touch any pointer belong to previous kernel at the crash
> > time.  But without this code, MPT fusion driver is very likely unable
> > to restart. It sometimes failed to restart even with the irq->end
> > code. This is an open issue need to be fixed.
>=20
> Right, that does sound quite nicely, especially as that device is quite
> common, right?
>=20
  That is a standard device for some server platforms like Tiger.

Thanks=20
Zou Nan hai
> --
> Horms
> H: http://www.vergenet.net/~horms/          W: http://www.valinux.co.jp/e=
n/
