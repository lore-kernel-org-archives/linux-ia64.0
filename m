From: Andi Kleen <ak@suse.de>
Date: Sat, 14 Jan 2006 01:19:39 +0000
Subject: Re: [PATCH 2.6.15] ia64: use i386 dmi_scan.c
Message-Id: <200601140219.39765.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com> <20060106223932.GB9230@lists.us.dell.com> <200601131724.42054.bjorn.helgaas@hp.com>
In-Reply-To: <200601131724.42054.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Matt Domsch <Matt_Domsch@dell.com>, linux-ia64@vger.kernel.org, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-kernel@vger.kernel.org

On Saturday 14 January 2006 01:24, Bjorn Helgaas wrote:
> On Friday 06 January 2006 15:39, Matt Domsch wrote:
> > diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
> > ...
> > +config DMI
> > +=A0=A0=A0=A0=A0=A0=A0bool
> > +=A0=A0=A0=A0=A0=A0=A0default y
>
> Should we have a way to turn this off?

At least on i386/x86-64 it is largely used for hardware/firmware bug=20
workaround and these have been traditionally always compiled in

Or do you want to spend a lot of time on a bug report from
a user only to discover they didn't enable the workarounds for
their particular platform?

You might not need that right now but I can predict that=20
at some point you'll need board specific workarounds - and
then it will be very useful to have.

>
> > diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
> > ...
> > +dmi_scan-y=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0+=3D ../../i386/kernel/dmi_scan.o
>
> Ugh.  I really hate this sort of sharing.  Could dmi_scan.c go in
> drivers/firmware/ or something instead?

Well, i suppose it will be more common in the future. Perhaps
get over that particular hatered?

-Andi
