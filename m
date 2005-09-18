From: Tony Luck <tony.luck@gmail.com>
Date: Sun, 18 Sep 2005 06:33:57 +0000
Subject: Re: 2.6.14-rc1 breaks tg3 on ia64
Message-Id: <12c511ca050917233313418638@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <25288.1126596450@kao2.melbourne.sgi.com>
	 <12c511ca05091708476aa136cd@mail.gmail.com>
	 <20050917155911.GB19854@tuxdriver.com>
	 <20050917.232304.31192760.davem@davemloft.net>
In-Reply-To: <20050917.232304.31192760.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>
Cc: linville@tuxdriver.com, kaos@sgi.com, greg@kroah.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

> It fixes the problem, but it's a hack, and I, perhaps like Tony,
> personally would like to know why the these IA64 systems break for
> such a simple operation such as writing some base registers with
> values we've probed already.

It does sound odd[1] that you can't rewrite the BARs to the values that
they should already have.  But I'm willing to wait to see what SGI's
solution that fixes this inside arch/ia64/sn/ looks like before making
any judgements.

-Tony

[1] odd = PCI spec violating?
