From: Alex Williamson <alex.williamson@hp.com>
Date: Thu, 23 Feb 2006 16:36:41 +0000
Subject: RE: [PATCH] ia64: avoid broken SAL_CACHE_FLUSH implementations
Message-Id: <1140712601.21338.183.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601301511.57109.bjorn.helgaas@hp.com>
In-Reply-To: <200601301511.57109.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-02-17 at 12:03 -0800, Luck, Tony wrote:

> Sometimes I forget to test patches against my zx2000 workstation (because
> it is such a pain to restart all my apps after I reboot).  This patch
> slipped through.  My zx2000 hasn't been booting since 2.6.15 and I
> finally spent the time to track down why.  It hangs (or dies) inside
> check_sal_cache_flush() :-(

Tony,

   What firmware version do you have on your zx2000?  I saw the same
problem with my zx2000 running firmware 2.21 and was hacking at a work
around, when I realized version 2.31 is available on the HP website.
After upgrading, I don't see the hang any more.  Bjorn mentioned that he
hasn't been able to reproduce the problem on his zx2000, probably
because he has the latest firmware.  Please check and let us know.
Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

