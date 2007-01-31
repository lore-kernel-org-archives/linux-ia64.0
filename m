From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Wed, 31 Jan 2007 06:07:24 +0000
Subject: RE: [Fastboot] [PATCH] kexec: Avoid migration of already disabled irqs (ia64)
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086BC7@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <45C005C1.5010606@sgi.com>
In-Reply-To: <45C005C1.5010606@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: Magnus Damm [mailto:magnus.damm@gmail.com]
> Sent: 2007=C4=EA1=D4=C231=C8=D5 13:58
> To: Zou, Nanhai
> Cc: Jay Lan; Magnus Damm; linux-ia64@vger.kernel.org; Luck, Tony;
> fastboot@lists.osdl.org
> Subject: Re: [Fastboot] [PATCH] kexec: Avoid migration of already disable=
d irqs
> (ia64)
>=20
> Hi Nan hai,
>=20
> On 1/31/07, Zou, Nanhai <nanhai.zou@intel.com> wrote:
> > > On 1/31/07, Jay Lan <jlan@sgi.com> wrote:
> > > > Magnus Damm wrote:
> > > > > kexec: Avoid migration of already disabled irqs (ia64)
> > > > >
> > > > > This patch fixes up ia64 kexec support for HP rx2620 hardware. It=
 does
> this
> > > > > by skipping migration of already disabled irqs. This is most like=
ly
> a problem
> > > > > on other ia64 platforms as well, but I've only tested this on one=
 machine
> > > > > so far.
> > > >
> > > > I have not seen this problem on SN systems.
> > >
> > > Ok, thanks. Let me give you more details.
> > >
> > > When I perform "kexec -e" the following output appears on my serial
> > > console (with my patch applied).
> >
> >  This patch is correct I think. I assume you will also see this bug whe=
n trying
> to offline a CPU by echo 0 > /sys/devices/system/cpu/cpuX/online
>=20
> You are right, I can trigger the bug that way too.
> And the bug goes away with the patch. Excellent!
>=20
> > However it will not be triggered in crash dump case which has been test=
ed
> heavily on different kind of platforms. We do not migrate IRQ at the time=
 of
> crash. I guess that is why Jay has never seen it on SN platforms.
>=20
> Booting into a crash kernel does not seem to work on this ia64 box
> unfortunately. I'm about to investigate why, but I thought trying and
> fixing kexec was a good first step.
>=20
  That is probably caused by HP's IOMMU engine not shutting down at crash t=
ime....,=20
Please try add machvec=3Ddig option for the crash dump kernel.
  However we still need to find a light way to correctly shutdown IOMMU eng=
ine on those HP platforms.

Thanks
Zou Nan hai
> Thanks for the help!

>=20
> / magnus
