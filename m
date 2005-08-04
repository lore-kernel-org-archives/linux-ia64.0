From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 04 Aug 2005 04:08:29 +0000
Subject: Re: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <17137.38077.975629.777885@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


After I sorted out the console problem, it turns out that the MPT
fusion driver is no longer enabled in the ZX1_defconfig.

Should it be?  What machines is configs/zx1_defconfig supposed to
cover?  I thought it was for all non-NUMA HP machines with a ZX1
chipset --- zx2000, rx2600, etc.

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
