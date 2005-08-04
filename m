From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 04 Aug 2005 01:42:08 +0000
Subject: Re: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <17137.29296.265484.891374@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Andreas" = Andreas Schwab <schwab@suse.de> writes:

Andreas> I can't get 2.6.13-rc5 to boot, it crashes very early without
Andreas> any sign of life, not even kdb can catch it.  Any idea?

I'm seeing a similar problem with ZX machines... and serial console
*is* enabled...

I used configs/zx1_defconfig

Peter c
-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
