From: Jeff Garzik <jgarzik@pobox.com>
Date: Mon, 26 Jan 2004 17:39:42 +0000
Subject: Re: ethtool -d MCAs rx2600
Message-Id: <401550DE.90906@pobox.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040123231254.GC31911@cup.hp.com>
In-Reply-To: <20040123231254.GC31911@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew Wilcox wrote:
> On Mon, Jan 26, 2004 at 10:30:23AM -0600, Jack Steiner wrote:
>>Looks like it occurs here (but I dont put a lot of faith in this):
>>        GET_REG32_LOOP(BUFMGR_MODE, 0x58);
>>        GET_REG32_LOOP(RDMAC_MODE, 0x08);
>>   >>>> GET_REG32_LOOP(WDMAC_MODE, 0x08);
>>        GET_REG32_LOOP(RX_CPU_BASE, 0x280);
>>        GET_REG32_LOOP(TX_CPU_BASE, 0x280);
> 
> 
> My suspicion is that some tg3 variants don't support this register, but
> it's OK to read the register on x86 because it soft-fails.  Most ia64
> chipsets hard-fail so we need to avoid this.  Jeff, Dave, can you comment?


I get lockups occasionally on x86 too, but have had higher priority 
things to look at.  Since regdump is mainly an engineer's tool, we felt 
it was a "use at your own risk" feature.

But if we can fix it, all the better.

Tangent -- I would love for somebody to take this output and prettyprint 
it in userland ethtool package (d/l and cvs at 
http://sf.net/projects/gkernel/).

	Jeff



