From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Wed, 31 Jan 2007 04:54:33 +0000
Subject: RE: [Fastboot] [PATCH] kexec: Avoid migration of already disabled irqs (ia64)
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086BC6@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <45C005C1.5010606@sgi.com>
In-Reply-To: <45C005C1.5010606@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Magnus Damm [mailto:magnus.damm@gmail.com]
> Sent: 2007=C4=EA1=D4=C231=C8=D5 11:50
> To: Jay Lan
> Cc: Magnus Damm; linux-ia64@vger.kernel.org; Luck, Tony; Zou, Nanhai;
> fastboot@lists.osdl.org
> Subject: Re: [Fastboot] [PATCH] kexec: Avoid migration of already disable=
d irqs
> (ia64)
>=20
> On 1/31/07, Jay Lan <jlan@sgi.com> wrote:
> > Magnus Damm wrote:
> > > kexec: Avoid migration of already disabled irqs (ia64)
> > >
> > > This patch fixes up ia64 kexec support for HP rx2620 hardware. It doe=
s this
> > > by skipping migration of already disabled irqs. This is most likely a=
 problem
> > > on other ia64 platforms as well, but I've only tested this on one mac=
hine
> > > so far.
> >
> > I have not seen this problem on SN systems.
>=20
> Ok, thanks. Let me give you more details.
>=20
> When I perform "kexec -e" the following output appears on my serial
> console (with my patch applied).

 This patch is correct I think. I assume you will also see this bug when tr=
ying to offline a CPU by echo 0 > /sys/devices/system/cpu/cpuX/online

However it will not be triggered in crash dump case which has been tested h=
eavily on different kind of platforms. We do not migrate IRQ at the time of=
 crash. I guess that is why Jay has never seen it on SN platforms.
=20
Thanks
Zou Nan hai
