From: "David S. Miller" <davem@davemloft.net>
Date: Tue, 13 Sep 2005 06:47:52 +0000
Subject: Re: 2.6.14-rc1 breaks tg3 on ia64
Message-Id: <20050912.234752.28084588.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050912.223755.56102921.davem@davemloft.net>
	<23056.1126592253@kao2.melbourne.sgi.com>
In-Reply-To: <23056.1126592253@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kaos@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

From: Keith Owens <kaos@sgi.com>
Date: Tue, 13 Sep 2005 16:17:33 +1000

> No, the 2.6.13 driver in 2.6.14-rc1 has exactly the same problem.
> 
> The last time that tg3 broke like this, it was because of the patch
> below, in 2.6.13-rc6.  That was backed out in 2.6.13-rc7.  Was the PCI
> patch (or equivalent) reinstated in 2.6.14-rc1?

It was reinstated, with a fix for the sparc64 problems it caused.
I wasn't aware of any ia64 regressions introduced by it.
