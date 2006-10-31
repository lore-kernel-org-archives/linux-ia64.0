From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Tue, 31 Oct 2006 04:33:33 +0000
Subject: RE: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086B05@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546623D.5000105@engr.sgi.com>
In-Reply-To: <4546623D.5000105@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: Jay Lan [mailto:jlan@sgi.com]
> Sent: 2006=C4=EA10=D4=C231=C8=D5 10:53
> To: Zou, Nanhai
> Cc: fastboot; Linux-IA64; Jack Steiner; Luck, Tony
> Subject: Re: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
>=20
> Zou, Nanhai wrote:
> >> -----Original Message-----
> >> From: Jay Lan [mailto:jlan@engr.sgi.com]
> >> Sent: 2006A"=A8=BA10O^A^31E`O~ 4:36
> >> To: fastboot
> >> Cc: Linux-IA64; Zou, Nanhai; Jack Steiner; Luck, Tony
> >> Subject: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
> >>
> >> This patch is to fix a problem of interrupts being sent to cpus
> >> that can not respond.
> >>
> >> This patch would return slave cpus to SAL slave loop, at time of
> >> crash, except cpu0. The cpu0 is a special case as there is no way
> >> to return it to SAL, so cpu0 is better handled in firmware.
> >>
> >> Signed-off-by: Jay Lan <jlan@sgi.com>
> >>
> >
> >
> > Does this fix the I/O interrupt redirect issue on SN?
>=20
> This fixes the interrupts being sent to cpus not in the
> slave loop that caused hang on SN. When one boots up the
> kexec'ed kernel with 'maxcpus=3D1', all idle cpus needs to
> be sent back. If they are not returned to the SAL slave
> loop and just looping in cpu_relax(), they are considered
> alive, but interrupts would be lost and system hang.
>=20

 But this will rely on machine crash on CPU 0?
 Current Kdump will boot to second kernel on the crashing CPU.=20
 So if machine crash and boot on CPU N, CPU 0 will still not be able to red=
irect interrupt, right? =20

> This is different from the kexec '--noio' option you added
> to kexec-tools. We still need that fix.
>=20


 Does --noio patch works on SN? I remember you have mentioned there is stil=
l some issue when you testing --noio option on SN system?

> > However this patch will make Kdump depends on cpu hotplug code, so you =
may
> add the dependency in Kconfig.
>=20
> I thought Kahalid Aziz's patch covered this?
> http://lists.osdl.org/mailman/htdig/fastboot/2006-October/004548.html
>=20

> Thanks,
>  - jay
>=20
> >
> > Thanks
> > Zou Nan hai
