From: Grant Grundler <iod00d@hp.com>
Date: Thu, 29 Jan 2004 19:18:37 +0000
Subject: Re: ethtool -d MCAs rx2600
Message-Id: <20040129191837.GE13404@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040123231254.GC31911@cup.hp.com>
In-Reply-To: <20040123231254.GC31911@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jan 26, 2004 at 12:39:42PM -0500, Jeff Garzik wrote:
> I get lockups occasionally on x86 too, but have had higher priority 
> things to look at.  Since regdump is mainly an engineer's tool, we felt 
> it was a "use at your own risk" feature.
> 
> But if we can fix it, all the better.

tg3_get_regs() is reading registers that don't exist.
Neither HPUX nor tru64 drivers attempt to touch NVRAM on BCM5700/1 chips.
And tg3 in most other places doesn't either.
It just needs to check TG3_FLAG_NVRAM before reading NVRAM regs.

Jack, you also using the bcm5701 chip?

Jeff, please apply. Following patch is against 2.6.2-rc2.

thanks,
grant

=== drivers/net/tg3.c 1.81 vs edited ==--- 1.81/drivers/net/tg3.c	Wed Dec 31 23:40:32 2003
+++ edited/drivers/net/tg3.c	Thu Jan 29 10:19:46 2004
@@ -5904,7 +5904,9 @@
 	GET_REG32_LOOP(MSGINT_MODE, 0x0c);
 	GET_REG32_1(DMAC_MODE);
 	GET_REG32_LOOP(GRC_MODE, 0x4c);
-	GET_REG32_LOOP(NVRAM_CMD, 0x24);
+	if (tp->tg3_flags & TG3_FLAG_NVRAM) {
+		GET_REG32_LOOP(NVRAM_CMD, 0x24);
+	}
 
 #undef __GET_REG32
 #undef GET_REG32_LOOP
