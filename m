From: Jack Steiner <steiner@sgi.com>
Date: Mon, 26 Jan 2004 16:30:23 +0000
Subject: Re: ethtool -d MCAs rx2600
Message-Id: <20040126163022.GC22070@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040123231254.GC31911@cup.hp.com>
In-Reply-To: <20040123231254.GC31911@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 23, 2004 at 03:56:50PM -0800, Grant Grundler wrote:
> On Fri, Jan 23, 2004 at 03:12:54PM -0800, Grant Grundler wrote:
> > In case someone wants to dig more now, I've dropped the "errdump mca"
> > output on
> > 	ftp://gsyprf10.external.hp.com/kernels/rx2600/mca_ethtool
> > 
> > (Matching vmlinuz, System.map, .config is also there 2.6.1-rc1.tgz)
> 
> Alex Williams tells me it's a PIO read timeout.
> (confirms my guess given what man page said)
> 
> Offending address is likely 0x0000000090807000.
> Matches nicely with what /proc/iomem thinks:
> ...
> 90000000-97ffffff : PCI Bus 0000:20
>   90800000-9080ffff : tg3
> ...
> 
> Now just need to hunt down the code that pokes at +0x7000.
> 
> thanks,
> grant

We see a similar problem with "ethtool -d" on the SGI SN systems. We havent
isolated the cause, but it looks similar - PIO read timeout.

FWIW, the failure occurs in the vicinity of tg3_get_regs+0xb60 called from
tg3_ethtool_ioctl+0xbb0.  (This is on 2.4.21+).  

Looks like it occurs here (but I dont put a lot of faith in this):
        GET_REG32_LOOP(BUFMGR_MODE, 0x58);
        GET_REG32_LOOP(RDMAC_MODE, 0x08);
   >>>> GET_REG32_LOOP(WDMAC_MODE, 0x08);
        GET_REG32_LOOP(RX_CPU_BASE, 0x280);
        GET_REG32_LOOP(TX_CPU_BASE, 0x280);


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


