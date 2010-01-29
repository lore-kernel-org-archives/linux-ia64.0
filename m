From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 29 Jan 2010 16:14:30 +0000
Subject: Re: "new" dependencies on ACPI/BIOS
Message-Id: <201001290914.31576.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4b61e3dc10565c4ca6@agluck-desktop.sc.intel.com>
In-Reply-To: <4b61e3dc10565c4ca6@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thursday 28 January 2010 07:14:54 pm Tony Luck wrote:
> On Thu, Jan 28, 2010 at 3:41 PM, Bjorn Helgaas <bjorn.helgaas@hp.com> wro=
te:
> > I don't see the connection between the commits you identified and
> > the fact that we don't find any host bridge memory windows.
> >
> > The problem I see is that the PNP0A08:00 host bridge has a bunch
> > of memory resources that are marked as "Consumer," which means the
> > bridge doesn't forward those regions downstream. =A0It's normal for
> > a bridge to have a couple things like that, e.g., 0xcf8, which the
> > bridge consumes and turns into config space accesses downstream,
> > but most of these are huge regions that are obviously supposed to
> > be Producer, not Consumer.
> >
> > That would certainly explain why the downstream devices don't work,
> > but it doesn't explain why they worked prior to 2.6.31. =A0We've been
> > checking that Producer/Consumer bit since 463eb297401e in 2005.
> >
> > Are you sure there wasn't a BIOS change at the time things broke?
> > I guess if you bisected it, there shouldn't be a BIOS change in the
> > middle, but I just don't see how this could ever have worked with
> > the _CRS we're getting from the BIOS.
> >
> Bjorn,
>=20
> Thanks for the help on this.  There was a BIOS change, but I don't
> think that it is connected to this. I don't have any old boot logs from
> the old BIOS, but I can definitely build & boot old kernels like
> 2.6.29 on the new BIOS and see all the devices.
>=20
> One theory for how old kernels managed to work is that when
> pci_create_bus() is called it initially sets resource[0] to map
> all possible IO space, and resource[1] to map all MEM space.
> In the current kernel these get overwritten with the actual
> windows before we do anything with them. But perhaps in
> the old kernel (before Willy changed the ordering) we might
> have accepted by ehci devices while the bus apparently mapped
> everything?

Maybe so.  All HP ia64 boxes have multiple host bridges, so it
seems like using those default IO and MEM resources would have
broken any Linux resource assignments, like for hotplug and option
ROM mapping.  But those haven't been tested very much, so maybe we
just didn't notice.  Anyway, I don't have a better idea.

> > resource_to_window() ignores consumer-only resources, which explains
> > why we aren't treating these memory descriptors as host bridge windows.
>=20
> I commented out that check in resource_to_window() ... and
> my system booted with a lot more windows reported, and
> all the devices working.  So a good theory for what is wrong
> is that the BIOS has all the right windows listed in _CRS, but
> it just has the wrong flags on some/all of them. But in particular
> this one:
>=20
> > DWORD addr space descriptor: [mem 0x50000000-0x9fffffff]
> >
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 8a 2b 00 00 0d 01 ff ff ff 03 00 00
> >> =A0 00 00 00 00 00 00 00 01 00 00 fe ff ff ff 00 01
> >> =A0 00 00 00 00 00 00 00 00 00 00 ff ff ff ff 00 00
> >> =A0 00 00
>=20
> I'll see if I can find the BIOS people for this platform and ask
> them if they can change the 'd' to a 'c'.

I would expect the incorrect flags to break Windows as well.

HP host bridges are ACPI devices, not PCI devices, and they have
both consumer resources (for configuration of the host bridge
device itself) and producer resources (windows that are forwarded
downstream).  If we ignored the flag, we'd treat those bridge
configuration resources as windows, which would be wrong.

Bjorn
