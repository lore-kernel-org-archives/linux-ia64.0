From: David Woodhouse <dwmw2@infradead.org>
Date: Mon, 12 Dec 2005 09:38:15 +0000
Subject: Re: [2.6 patch] defconfig's shouldn't set CONFIG_BROKEN=y
Message-Id: <1134380295.10234.62.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051211185212.GQ23349@stusta.de>
	 <20051211192109.GA22537@flint.arm.linux.org.uk>
	 <20051211193118.GR23349@stusta.de>
In-Reply-To: <20051211193118.GR23349@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, matthew@wil.cx, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, paulus@samba.org, linuxppc-dev@ozlabs.org, lethal@linux-sh.org, kkojima@rr.iij4u.or.jp, linux-mtd@lists.infradead.xn--org-boa

On Sun, 2005-12-11 at 20:31 +0100, Adrian Bunk wrote:
> Either the depency of MTD_OBSOLETE_CHIPS on BROKEN is correct (in
> which case CONFIG_MTD_OBSOLETE_CHIPS=y wouldn't bring you anything),
> or the dependency on BROKEN is not correct and should be corrected.
> 
> David, can you comment on this issue?

I don't see any justification for MTD_OBSOLETE_CHIPS depending on
BROKEN. That option covers a few of the obsolete chip drivers which
people shouldn't be using any more -- and I'm perfectly willing to
believe that one or two of those don't work any more, but if that's the
case then those individual drivers ought to be marked BROKEN (or just
removed). We shouldn't mark MTD_OBSOLETE_CHIPS broken.

I'd like to see the collie_defconfig updated to use the appropriate CFI
driver back end.

-- 
dwmw2

