From: Lukas Bulwahn <lukas.bulwahn@gmail.com>
Date: Tue, 18 Feb 2020 20:14:53 +0000
Subject: RE: [PATCH] tty/serial: cleanup after ioc*_serial driver removal
Message-Id: <alpine.DEB.2.21.2002182112520.3368@felia>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200217081558.10266-1-lukas.bulwahn@gmail.com> <CADxRZqwGBi=4A224mG0cPgONdNitnvi3LFD_KQckxdYSXzgBGg@mail.gmail.com> <alpine.DEB.2.21.2002170950390.11007@felia> <3908561D78D1C84285E8C5FCA982C28F7F57B7D6@ORSMSX115.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7F57B7D6@ORSMSX115.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Lukas Bulwahn <lukas.bulwahn@gmail.com>, Anatoly Pugachev <matorola@gmail.com>, Pat Gefre <pfg@sgi.com>, Christoph Hellwig <hch@lst.de>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Joe Perches <joe@perches.com>, "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>, Linux Kernel list <linux-kernel@vger.kernel.org>



On Tue, 18 Feb 2020, Luck, Tony wrote:

> > I do not know if there are more ia64 serial drivers, but the MAINTAINERS 
> > entry and commit message suggested there is not another serial driver.
> 
> Lukas,
> 
> There aren't any other ia64 specific serial drivers. But ia64 does use generic
> serial drivers (e.g. my test machine has a couple of serial ports attached to 16550A
> devices)
> 
> I think some notes in that documentation file still apply. Please don't delete.
> 

I provided a PATCH v2 that does not delete the documentation, which 
already was reviewed by Christoph Hellwig.

Please pick and apply that PATCH v2.

Lukas 
