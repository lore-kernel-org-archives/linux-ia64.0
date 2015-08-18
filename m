From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Tue, 18 Aug 2015 22:45:33 +0000
Subject: Re: [RFT PATCH] ia64: zx1_defconfig: convert to use libata PATA drivers
Message-Id: <CAA9xbM7r-HfvuUg00D94rgokWhP_Qes71UAbN_24dmFpSiNtAg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439826388-31456-1-git-send-email-b.zolnierkie@samsung.com>
	<1439826388-31456-5-git-send-email-b.zolnierkie@samsung.com>
	<CAA9xbM52onBKCw9i=_ar0W67651JpJnRTj6AeVsmJ4UAtzubew@mail.gmail.com>
	<3908561D78D1C84285E8C5FCA982C28F32ADECD4@ORSMSX114.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32ADECD4@ORSMSX114.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

2015-08-17 22:41 GMT+02:00 Luck, Tony <tony.luck@intel.com>:
>
> Do you have PATA drives?  My zx6000 just has SCSI:

Yes Sir, the internal DVD drive (TEAC DV-28E-B [1]):

emeric@longspeak ~ $ dmesg | grep ATA
[    0.947229] ata1: PATA max UDMA/100 cmd 0xd58 ctl 0xd64 bmdma 0xd40 irq =
54
[    1.103782] ata1.00: ATAPI: DV-28E-B, 2.2B, max UDMA/33

     =C3=89meric

[1] http://www.teac.co.jp/dspd/product/optical/dv-28eb.html
