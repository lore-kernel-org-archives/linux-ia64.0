From: Grant Grundler <iod00d@hp.com>
Date: Fri, 23 Jan 2004 23:56:50 +0000
Subject: Re: ethtool -d MCAs rx2600
Message-Id: <20040123235650.GF31911@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040123231254.GC31911@cup.hp.com>
In-Reply-To: <20040123231254.GC31911@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 23, 2004 at 03:12:54PM -0800, Grant Grundler wrote:
> In case someone wants to dig more now, I've dropped the "errdump mca"
> output on
> 	ftp://gsyprf10.external.hp.com/kernels/rx2600/mca_ethtool
> 
> (Matching vmlinuz, System.map, .config is also there 2.6.1-rc1.tgz)

Alex Williams tells me it's a PIO read timeout.
(confirms my guess given what man page said)

Offending address is likely 0x0000000090807000.
Matches nicely with what /proc/iomem thinks:
...
90000000-97ffffff : PCI Bus 0000:20
  90800000-9080ffff : tg3
...

Now just need to hunt down the code that pokes at +0x7000.

thanks,
grant
