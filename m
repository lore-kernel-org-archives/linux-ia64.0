From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Sat, 14 Jan 2006 05:05:30 +0000
Subject: Re: [PATCH 2.6.15] ia64: use i386 dmi_scan.c
Message-Id: <200601132205.30675.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com> <200601131724.42054.bjorn.helgaas@hp.com> <200601140219.39765.ak@suse.de>
In-Reply-To: <200601140219.39765.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Andi Kleen <ak@suse.de>
Cc: Matt Domsch <Matt_Domsch@dell.com>, linux-ia64@vger.kernel.org, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-kernel@vger.kernel.org

On Friday 13 January 2006 18:19, Andi Kleen wrote:
> On Saturday 14 January 2006 01:24, Bjorn Helgaas wrote:
> > On Friday 06 January 2006 15:39, Matt Domsch wrote:
> > > diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
> > > ...
> > > +config DMI
> > > +=A0=A0=A0=A0=A0=A0=A0bool
> > > +=A0=A0=A0=A0=A0=A0=A0default y
> >
> > Should we have a way to turn this off?
>=20
> At least on i386/x86-64 it is largely used for hardware/firmware bug=20
> workaround and these have been traditionally always compiled in
>=20
> Or do you want to spend a lot of time on a bug report from
> a user only to discover they didn't enable the workarounds for
> their particular platform?

Yeah, that was a dumb idea.  I just need to fix whatever's
currently broken and then there'll be no harm in having it
all the time.
