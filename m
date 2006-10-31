From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Tue, 31 Oct 2006 02:02:59 +0000
Subject: RE: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086B04@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546623D.5000105@engr.sgi.com>
In-Reply-To: <4546623D.5000105@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: Jay Lan [mailto:jlan@engr.sgi.com]
> Sent: 2006=C4=EA10=D4=C231=C8=D5 4:36
> To: fastboot
> Cc: Linux-IA64; Zou, Nanhai; Jack Steiner; Luck, Tony
> Subject: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
>=20
> This patch is to fix a problem of interrupts being sent to cpus
> that can not respond.
>=20
> This patch would return slave cpus to SAL slave loop, at time of
> crash, except cpu0. The cpu0 is a special case as there is no way
> to return it to SAL, so cpu0 is better handled in firmware.
>=20
> Signed-off-by: Jay Lan <jlan@sgi.com>
>=20


Does this fix the I/O interrupt redirect issue on SN?
However this patch will make Kdump depends on cpu hotplug code, so you may =
add the dependency in Kconfig.

Thanks
Zou Nan hai
