From: Christoph Hellwig <hch@lst.de>
Date: Tue, 13 Feb 2018 01:44:12 +0000
Subject: Re: [PATCH] ia64: Remove pci-swiotlb.o from kernel Makefile
Message-Id: <20180213014412.GA3303@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1518474733-2972-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1518474733-2972-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guenter Roeck <linux@roeck-us.net>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>

Thanks Guenter,

I actually got a similar report a few days ago and prepared the same
patch as part of the dma-mapping fixup series I'm about to send out:

	http://git.infradead.org/users/hch/misc.git/commitdiff/f9f787e3fe227329d27768566e925e4d94c5f517
