From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Mon, 20 Sep 2004 19:01:28 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[1/6]-ACPI core enhancement support
Message-Id: <20040920120128.A15677@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com> <20040920093402.C14208@unix-os.sc.intel.com> <200409201326.44946.dtor_core@ameritech.net>
In-Reply-To: <200409201326.44946.dtor_core@ameritech.net>; from dtor_core@ameritech.net on Mon, Sep 20, 2004 at 01:26:44PM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Dmitry Torokhov <dtor_core@ameritech.net>
Cc: acpi-devel@lists.sourceforge.net, Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>, "Brown, Len" <len.brown@intel.com>, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Mon, Sep 20, 2004 at 01:26:44PM -0500, Dmitry Torokhov wrote:
> On Monday 20 September 2004 11:34 am, Keshavamurthy Anil S wrote:
> > +void
> > +acpi_bus_trim(struct acpi_device=A0=A0=A0=A0=A0=A0=A0*start,
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0int rmdevice)
> > +{
> > +=A0=A0=A0=A0=A0=A0=A0acpi_status=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0status =3D AE_OK;
> > +=A0=A0=A0=A0=A0=A0=A0struct acpi_device=A0=A0=A0=A0=A0=A0*parent =3D N=
ULL;
> > +=A0=A0=A0=A0=A0=A0=A0struct acpi_device=A0=A0=A0=A0=A0=A0*child =3D NU=
LL;
> > +=A0=A0=A0=A0=A0=A0=A0acpi_handle=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0phandle =3D 0;
> > +=A0=A0=A0=A0=A0=A0=A0acpi_handle=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0chandle =3D 0;
> > +
> > +=A0=A0=A0=A0=A0=A0=A0parent =A0=3D start;
> > +=A0=A0=A0=A0=A0=A0=A0phandle =3D start->handle;
>=20
>=20
> Why do all these variables have to be initialized? parent and phandle are
> set up explicitly couple of lines below, the rest is only used safely
> as well...
You are correct, variable initialization can be removed. I will do this.

>=20
> Also, introducing recursion (depth does not seem to be limited here) is
> not a good idea IMHO - better convert it into iteration to avoid stack
> problems down teh road.
Humm, I guess recursion should be fine and even though the code does not ha=
ve
an explicit limit, the ACPI namespace describing the Ejectable device will =
limit the
number of recursible devices. And I believe this won;t be more than 3 to 4 =
level depth.
Hence recursion is fine here.

If you still strongly believe that recursion is not the right choice here, =

let me know and I will convert it to iteration.

Thanks,
Anil
