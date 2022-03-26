From: Joe Perches <joe@perches.com>
Date: Sat, 26 Mar 2022 19:51:44 +0000
Subject: Re: [PATCH 16/22] dvb-usb: Replace comments with C99 initializers
Message-Id: <63a5e3143e904d1391490f27cc106be894b52ca2.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
         <20220326165909.506926-16-benni@stuerz.xyz>
         <20220326192454.14115baa@coco.lan> <20220326192720.0fddd6dd@coco.lan>
In-Reply-To: <20220326192720.0fddd6dd@coco.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Mauro Carvalho Chehab <mchehab@kernel.org>, Benjamin =?ISO-8859-1?Q?St=FCrz?= <benni@stuerz.xyz>
Cc: andrew@lunn.ch, sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

On Sat, 2022-03-26 at 19:27 +0100, Mauro Carvalho Chehab wrote:
> Em Sat, 26 Mar 2022 19:24:54 +0100
> Mauro Carvalho Chehab <mchehab@kernel.org> escreveu:
>=20
> > Em Sat, 26 Mar 2022 17:59:03 +0100
> > Benjamin St=FCrz <benni@stuerz.xyz> escreveu:
> >=20
> > > This replaces comments with C99's designated
> > > initializers because the kernel supports them now.
> > >=20
> > > Signed-off-by: Benjamin St=FCrz <benni@stuerz.xyz>
> > > ---
> > >  drivers/media/usb/dvb-usb/dibusb-mb.c | 62 +++++++++++++------------=
--
> > >  drivers/media/usb/dvb-usb/dibusb-mc.c | 34 +++++++--------
> > >  2 files changed, 48 insertions(+), 48 deletions(-)
> > >=20
> > > diff --git a/drivers/media/usb/dvb-usb/dibusb-mb.c b/drivers/media/us=
b/dvb-usb/dibusb-mb.c
> > > index e9dc27f73970..f188e07f518b 100644
> > > --- a/drivers/media/usb/dvb-usb/dibusb-mb.c
> > > +++ b/drivers/media/usb/dvb-usb/dibusb-mb.c
> > > @@ -122,40 +122,40 @@ static int dibusb_probe(struct usb_interface *i=
ntf,
> > > =20
> > >  /* do not change the order of the ID table */
> > >  static struct usb_device_id dibusb_dib3000mb_table [] =3D {
> > > -/* 00 */	{ USB_DEVICE(USB_VID_WIDEVIEW,		USB_PID_AVERMEDIA_DVBT_USB_=
COLD) },
> > > -/* 01 */	{ USB_DEVICE(USB_VID_WIDEVIEW,		USB_PID_AVERMEDIA_DVBT_USB_=
WARM) },
> > > -/* 02 */	{ USB_DEVICE(USB_VID_COMPRO,		USB_PID_COMPRO_DVBU2000_COLD)=
 },
> > > -/* 03 */	{ USB_DEVICE(USB_VID_COMPRO,		USB_PID_COMPRO_DVBU2000_WARM)=
 },
> > > -/* 04 */	{ USB_DEVICE(USB_VID_COMPRO_UNK,	USB_PID_COMPRO_DVBU2000_UN=
K_COLD) },
> > > -/* 05 */	{ USB_DEVICE(USB_VID_DIBCOM,		USB_PID_DIBCOM_MOD3000_COLD) =
},
> > > -/* 06 */	{ USB_DEVICE(USB_VID_DIBCOM,		USB_PID_DIBCOM_MOD3000_WARM) =
},
> > > -/* 07 */	{ USB_DEVICE(USB_VID_EMPIA,		USB_PID_KWORLD_VSTREAM_COLD) },
> > > -/* 08 */	{ USB_DEVICE(USB_VID_EMPIA,		USB_PID_KWORLD_VSTREAM_WARM) },
> > > -/* 09 */	{ USB_DEVICE(USB_VID_GRANDTEC,		USB_PID_GRANDTEC_DVBT_USB_C=
OLD) },
> > > -/* 10 */	{ USB_DEVICE(USB_VID_GRANDTEC,		USB_PID_GRANDTEC_DVBT_USB_W=
ARM) },
> > > -/* 11 */	{ USB_DEVICE(USB_VID_GRANDTEC,		USB_PID_DIBCOM_MOD3000_COLD=
) },
> > > -/* 12 */	{ USB_DEVICE(USB_VID_GRANDTEC,		USB_PID_DIBCOM_MOD3000_WARM=
) },
> > > -/* 13 */	{ USB_DEVICE(USB_VID_HYPER_PALTEK,	USB_PID_UNK_HYPER_PALTEK=
_COLD) },
> > > -/* 14 */	{ USB_DEVICE(USB_VID_HYPER_PALTEK,	USB_PID_UNK_HYPER_PALTEK=
_WARM) },
> > > -/* 15 */	{ USB_DEVICE(USB_VID_VISIONPLUS,	USB_PID_TWINHAN_VP7041_COL=
D) },
> > > -/* 16 */	{ USB_DEVICE(USB_VID_VISIONPLUS,	USB_PID_TWINHAN_VP7041_WAR=
M) },
> > > -/* 17 */	{ USB_DEVICE(USB_VID_TWINHAN,		USB_PID_TWINHAN_VP7041_COLD)=
 },
> > > -/* 18 */	{ USB_DEVICE(USB_VID_TWINHAN,		USB_PID_TWINHAN_VP7041_WARM)=
 },
> > > -/* 19 */	{ USB_DEVICE(USB_VID_ULTIMA_ELECTRONIC,	USB_PID_ULTIMA_TVBO=
X_COLD) },
> > > -/* 20 */	{ USB_DEVICE(USB_VID_ULTIMA_ELECTRONIC,	USB_PID_ULTIMA_TVBO=
X_WARM) },
> > > -/* 21 */	{ USB_DEVICE(USB_VID_ULTIMA_ELECTRONIC,	USB_PID_ULTIMA_TVBO=
X_AN2235_COLD) },
> > > -/* 22 */	{ USB_DEVICE(USB_VID_ULTIMA_ELECTRONIC,	USB_PID_ULTIMA_TVBO=
X_AN2235_WARM) },
> > > -/* 23 */	{ USB_DEVICE(USB_VID_ADSTECH,		USB_PID_ADSTECH_USB2_COLD) },
> > > +[0]  =3D	{ USB_DEVICE(USB_VID_WIDEVIEW,		USB_PID_AVERMEDIA_DVBT_USB_=
COLD) },
> > > +[1]  =3D	{ USB_DEVICE(USB_VID_WIDEVIEW,		USB_PID_AVERMEDIA_DVBT_USB_=
WARM) }, =20
> >=20
> > While here, please properly indent this table, and respect the 80-colum=
ns limit,
> > e. g.:
> >=20
> > static struct usb_device_id dibusb_dib3000mb_table [] =3D {
> > 	[0] =3D { USB_DEVICE(USB_VID_WIDEVIEW=20
> > 			   USB_PID_AVERMEDIA_DVBT_USB_COLD)=20
> > 	},
> > 	[1]  =3D	{ USB_DEVICE(USB_VID_WIDEVIEW,
> > 			     USB_PID_AVERMEDIA_DVBT_USB_WARM)
> > 	},
> > 	...
>=20
> Err.... something went wrong with my space bar and I ended hitting send to
> soon... I meant:
>=20
> static struct usb_device_id dibusb_dib3000mb_table [] =3D {
>  	[0] =3D { USB_DEVICE(USB_VID_WIDEVIEW=20
>  			   USB_PID_AVERMEDIA_DVBT_USB_COLD)=20
>  	},
>  	[1] =3D { USB_DEVICE(USB_VID_WIDEVIEW,
>  			   USB_PID_AVERMEDIA_DVBT_USB_WARM)
>  	},
> 	...
> };

maybe static const too

and

maybe

#define DIB_DEVICE(vid, pid)	\
	{ USB_DEVICE(USB_VID_ ## vid, USB_PID_ ## pid) }

so maybe

static const struct usb_device_id dibusb_dib3000mb_table[] =3D {
	[0] =3D DIB_DEVICE(WIDEVIEW, AVERMEDIA_DVBT_USB_COLD),
	[1] =3D DIB_DEVICE(WIDEVIEW, AVERMEDIA_DVBT_USB_WARM),
	...
};

though I _really_ doubt the value of the specific indexing.

I think this isn't really worth changing at all.

