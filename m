From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Aug 2019 20:26:17 +0000
Subject: RE: remove sn2, hpsim and ia64 machvecs
Message-Id: <3908561D78D1C84285E8C5FCA982C28F7F4143CB@ORSMSX115.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190807133049.20893-1-hch@lst.de>
 <3908561D78D1C84285E8C5FCA982C28F7F41388B@ORSMSX115.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7F41388B@ORSMSX115.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Hellwig' <hch@lst.de>, "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: 'Arnd Bergmann' <arnd@arndb.de>, 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>

> Even if I explicitly run:
>
> $ make compressed
>
> It still doesn't build it.  Weird.

Ugh! The rule to do the compression was in arch/ia64/hp/sim/boot/Makefile
which went away as part of the deletion of hpsim.

-Tony
