From: Tony Luck <tony.luck@gmail.com>
Date: Fri, 17 Sep 2010 17:44:38 +0000
Subject: Re: [PATCH 0/2] ia64: possible module unwind table optimisation
Message-Id: <AANLkTinm6qSOGTzX1J-3R27o5KxGkx8Esg+iCbb3Wnu6@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1284115245-23876-1-git-send-email-ext-phil.2.carmody@nokia.com>
	<AANLkTi=RsA0tACWOg+8RTSuDHwa4LGOiyO-4TxpJ_rb5@mail.gmail.com>
	<20100915124831.GB27658@esdhcp04044.research.nokia.com>
	<AANLkTi=hPcXC1=Lrey1H_UHRJRJ-NdTsvmyxgP_n+dM8@mail.gmail.com>
	<20100915222216.GF27658@esdhcp04044.research.nokia.com>
	<AANLkTikgi38O3=MsVNc-X64PnLOFNktC_x9Y3vQ7CbD+@mail.gmail.com>
	<20100917084411.GC20325@esdhcp04044.research.nokia.com>
In-Reply-To: <20100917084411.GC20325@esdhcp04044.research.nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Phil Carmody <ext-phil.2.carmody@nokia.com>
Cc: "fenghua.yu@intel.com" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> This is a shame, but not a real problem in the context of my patch - you can't
> usefully optimise something that's seemingly almost never used. It can be filed
> in the cylindrical filing cabinet.

I'll probably apply it anyway ... it looks like it will be useful when
I get things like this
working.  The initial problem with kmemleak seems to be configuration related. I
cut back from 4096 cpus on 1024 nodes to a more modest 32 cpus on 8 nodes,
and my system boots.  Still can't test your patch because although debugfs got
configured and apparently built-in ok ... I can't see it in
/proc/filesystems, so it
won't mount.

Thanks

-Tony
