From: Russell King <rmk+lkml@arm.linux.org.uk>
Date: Sun, 11 Dec 2005 19:21:10 +0000
Subject: Re: [2.6 patch] defconfig's shouldn't set CONFIG_BROKEN=y
Message-Id: <20051211192109.GA22537@flint.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051211185212.GQ23349@stusta.de>
In-Reply-To: <20051211185212.GQ23349@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, matthew@wil.cx, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, paulus@samba.org, linuxppc-dev@ozlabs.org, lethal@linux-sh.org, kkojima@rr.iij4u.or.jp, linux-sh@m17n.org

On Sun, Dec 11, 2005 at 07:52:12PM +0100, Adrian Bunk wrote:
> defconfig's shouldn't set CONFIG_BROKEN=y.

NACK.  This changes other configuration options in addition, for example
in collie_defconfig:

-CONFIG_MTD_OBSOLETE_CHIPS=y
-# CONFIG_MTD_AMDSTD is not set
-CONFIG_MTD_SHARP=y
-# CONFIG_MTD_JEDEC is not set

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 Serial core
