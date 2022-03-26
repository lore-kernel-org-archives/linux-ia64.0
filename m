From: Mauro Carvalho Chehab <mchehab@kernel.org>
Date: Sat, 26 Mar 2022 18:27:20 +0000
Subject: Re: [PATCH 16/22] dvb-usb: Replace comments with C99 initializers
Message-Id: <20220326192720.0fddd6dd@coco.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
        <20220326165909.506926-16-benni@stuerz.xyz>
        <20220326192454.14115baa@coco.lan>
In-Reply-To: <20220326192454.14115baa@coco.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Benjamin =?UTF-8?B?U3TDvHJ6?= <benni@stuerz.xyz>
Cc: andrew@lunn.ch, sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

Em Sat, 26 Mar 2022 19:24:54 +0100
Mauro Carvalho Chehab <mchehab@kernel.org> escreveu:

> Em Sat, 26 Mar 2022 17:59:03 +0100
> Benjamin Stürz <benni@stuerz.xyz> escreveu:
> 
> > This replaces comments with C99's designated
> > initializers because the kernel supports them now.
> > 
> > Signed-off-by: Benjamin Stürz <benni@stuerz.xyz>
> > ---
> >  drivers/media/usb/dvb-usb/dibusb-mb.c | 62 +++++++++++++--------------
> >  drivers/media/usb/dvb-usb/dibusb-mc.c | 34 +++++++--------
> >  2 files changed, 48 insertions(+), 48 deletions(-)
> > 
> > diff --git a/drivers/media/usb/dvb-usb/dibusb-mb.c b/drivers/media/usb/dvb-usb/dibusb-mb.c
> > index e9dc27f73970..f188e07f518b 100644
> > --- a/drivers/media/usb/dvb-usb/dibusb-mb.c
> > +++ b/drivers/media/usb/dvb-usb/dibusb-mb.c
> > @@ -122,40 +122,40 @@ static int dibusb_probe(struct usb_interface *intf,
> >  
> >  /* do not change the order of the ID table */
> >  static struct usb_device_id dibusb_dib3000mb_table [] = {
> > -/* 00 */	{ USB_DEVICE(USB_VID_WIDEVIEW,		USB_PID_AVERMEDIA_DVBT_USB_COLD) },
> > -/* 01 */	{ USB_DEVICE(USB_VID_WIDEVIEW,		USB_PID_AVERMEDIA_DVBT_USB_WARM) },
> > -/* 02 */	{ USB_DEVICE(USB_VID_COMPRO,		USB_PID_COMPRO_DVBU2000_COLD) },
> > -/* 03 */	{ USB_DEVICE(USB_VID_COMPRO,		USB_PID_COMPRO_DVBU2000_WARM) },
> > -/* 04 */	{ USB_DEVICE(USB_VID_COMPRO_UNK,	USB_PID_COMPRO_DVBU2000_UNK_COLD) },
> > -/* 05 */	{ USB_DEVICE(USB_VID_DIBCOM,		USB_PID_DIBCOM_MOD3000_COLD) },
> > -/* 06 */	{ USB_DEVICE(USB_VID_DIBCOM,		USB_PID_DIBCOM_MOD3000_WARM) },
> > -/* 07 */	{ USB_DEVICE(USB_VID_EMPIA,		USB_PID_KWORLD_VSTREAM_COLD) },
> > -/* 08 */	{ USB_DEVICE(USB_VID_EMPIA,		USB_PID_KWORLD_VSTREAM_WARM) },
> > -/* 09 */	{ USB_DEVICE(USB_VID_GRANDTEC,		USB_PID_GRANDTEC_DVBT_USB_COLD) },
> > -/* 10 */	{ USB_DEVICE(USB_VID_GRANDTEC,		USB_PID_GRANDTEC_DVBT_USB_WARM) },
> > -/* 11 */	{ USB_DEVICE(USB_VID_GRANDTEC,		USB_PID_DIBCOM_MOD3000_COLD) },
> > -/* 12 */	{ USB_DEVICE(USB_VID_GRANDTEC,		USB_PID_DIBCOM_MOD3000_WARM) },
> > -/* 13 */	{ USB_DEVICE(USB_VID_HYPER_PALTEK,	USB_PID_UNK_HYPER_PALTEK_COLD) },
> > -/* 14 */	{ USB_DEVICE(USB_VID_HYPER_PALTEK,	USB_PID_UNK_HYPER_PALTEK_WARM) },
> > -/* 15 */	{ USB_DEVICE(USB_VID_VISIONPLUS,	USB_PID_TWINHAN_VP7041_COLD) },
> > -/* 16 */	{ USB_DEVICE(USB_VID_VISIONPLUS,	USB_PID_TWINHAN_VP7041_WARM) },
> > -/* 17 */	{ USB_DEVICE(USB_VID_TWINHAN,		USB_PID_TWINHAN_VP7041_COLD) },
> > -/* 18 */	{ USB_DEVICE(USB_VID_TWINHAN,		USB_PID_TWINHAN_VP7041_WARM) },
> > -/* 19 */	{ USB_DEVICE(USB_VID_ULTIMA_ELECTRONIC,	USB_PID_ULTIMA_TVBOX_COLD) },
> > -/* 20 */	{ USB_DEVICE(USB_VID_ULTIMA_ELECTRONIC,	USB_PID_ULTIMA_TVBOX_WARM) },
> > -/* 21 */	{ USB_DEVICE(USB_VID_ULTIMA_ELECTRONIC,	USB_PID_ULTIMA_TVBOX_AN2235_COLD) },
> > -/* 22 */	{ USB_DEVICE(USB_VID_ULTIMA_ELECTRONIC,	USB_PID_ULTIMA_TVBOX_AN2235_WARM) },
> > -/* 23 */	{ USB_DEVICE(USB_VID_ADSTECH,		USB_PID_ADSTECH_USB2_COLD) },
> > +[0]  =	{ USB_DEVICE(USB_VID_WIDEVIEW,		USB_PID_AVERMEDIA_DVBT_USB_COLD) },
> > +[1]  =	{ USB_DEVICE(USB_VID_WIDEVIEW,		USB_PID_AVERMEDIA_DVBT_USB_WARM) },  
> 
> While here, please properly indent this table, and respect the 80-columns limit,
> e. g.:
> 
> static struct usb_device_id dibusb_dib3000mb_table [] = {
> 	[0] = { USB_DEVICE(USB_VID_WIDEVIEW 
> 			   USB_PID_AVERMEDIA_DVBT_USB_COLD) 
> 	},
> 	[1]  =	{ USB_DEVICE(USB_VID_WIDEVIEW,
> 			     USB_PID_AVERMEDIA_DVBT_USB_WARM)
> 	},
> 	...

Err.... something went wrong with my space bar and I ended hitting send to
soon... I meant:

static struct usb_device_id dibusb_dib3000mb_table [] = {
 	[0] = { USB_DEVICE(USB_VID_WIDEVIEW 
 			   USB_PID_AVERMEDIA_DVBT_USB_COLD) 
 	},
 	[1] = { USB_DEVICE(USB_VID_WIDEVIEW,
 			   USB_PID_AVERMEDIA_DVBT_USB_WARM)
 	},
	...
};

Thanks,
Mauro
