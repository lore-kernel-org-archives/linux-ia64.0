From: Linus Torvalds <torvalds@transmeta.com>
Date: Tue, 12 Feb 2002 05:19:43 +0000
Subject: [Linux-ia64] Re: driver location for platform-specific drivers
Message-Id: <marc-linux-ia64-105590698806036@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806032@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806032@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, 11 Feb 2002, John Hesterberg wrote:
>
> For SGI's upcoming Linux platform (nicknamed Scalable Node, or SN),
> we have some platform specific device drivers.  Where should these go?
> I see several precedents in the current kernels.

If they are equivalent to a new bus, make a new platform directory under
drivers, is my vote.

However, if they are likely to eventually spread out (ie they are
really PCI-based, and just your own private chips, and they might end up
as part of some other sgi platform), spread them out as normal drivers.

		Linus


