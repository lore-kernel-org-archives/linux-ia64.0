From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Aug 2019 18:15:55 +0000
Subject: RE: remove sn2, hpsim and ia64 machvecs
Message-Id: <3908561D78D1C84285E8C5FCA982C28F7F41388B@ORSMSX115.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190807133049.20893-1-hch@lst.de>
In-Reply-To: <20190807133049.20893-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

I like the idea ... and it sure gets rid of a lot of code.

> A git tree is also available at:
>
>    git://git.infradead.org/users/hch/misc.git ia64-remove-machvecs

I grabbed this tree and ran though my build scripts.  I found that
vmlinux.gz doesn't get built.  Which is odd, because I don't see that
you changed the "compressed" target in the Makefile.

Even if I explicitly run:

$ make compressed

It still doesn't build it.  Weird.

-Tony
