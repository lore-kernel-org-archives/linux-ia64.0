From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Wed, 05 Apr 2006 01:34:56 +0000
Subject: RE: [Fastboot] [PATCH] kexec on ia64
Message-Id: <08B1877B2880CE42811294894F33AD5C053A86@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100551268.26287.35.camel@lyra.fc.hp.com>
In-Reply-To: <1100551268.26287.35.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: ebiederm@xmission.com, khalid_aziz@hp.com, linux-kernel@vger.kernel.org, fastboot@lists.osdl.org, linux-ia64@vger.kernel.org

> -----Original Message-----
> From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> Sent: 2006=C4=EA4=D4=C25=C8=D5 9:28
> To: Zou, Nanhai
> Cc: ebiederm@xmission.com; khalid_aziz@hp.com; linux-kernel@vger.kernel.o=
rg;
> fastboot@lists.osdl.org; linux-ia64@vger.kernel.org
> Subject: Re: [Fastboot] [PATCH] kexec on ia64
>=20
> On Wed, 5 Apr 2006 09:13:36 +0800
> "Zou, Nanhai" <nanhai.zou@intel.com> wrote:
> > > I'm working for memory hotplug. When memory is hot-added, memory layo=
ut
> > > changes.
> > > But I think there is no code to manage memory layout information of a=
dded
> memory.
> > >
> >  It reads memory layout from /proc/iomem...,
> >  If memory is hotpluged, I think we need a reload of kdump.
> >
> If /proc/iomem is updated at hotplug event (this is not updated now),
> is there no problem ?
>=20
 The crash dumping kernel also needs a reload, because the physical memory =
list is read and saved at kdump kernel loading time instead of crashing tim=
e.

Zou Nan hai
