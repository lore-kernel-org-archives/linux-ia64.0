From: "David S. Miller" <davem@davemloft.net>
Date: Sun, 18 Sep 2005 06:23:04 +0000
Subject: Re: 2.6.14-rc1 breaks tg3 on ia64
Message-Id: <20050917.232304.31192760.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <25288.1126596450@kao2.melbourne.sgi.com>
	<12c511ca05091708476aa136cd@mail.gmail.com>
	<20050917155911.GB19854@tuxdriver.com>
In-Reply-To: <20050917155911.GB19854@tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linville@tuxdriver.com
Cc: tony.luck@gmail.com, kaos@sgi.com, greg@kroah.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Sat, 17 Sep 2005 11:59:14 -0400

> I posted a patch on Wednesday:
> 
> 	http://www.ussg.iu.edu/hypermail/linux/kernel/0509.1/2193.html
> 
> The original reporter (Keith Owens <kaos@sgi.com>) confirmed this
> patch to fix the problem.

It fixes the problem, but it's a hack, and I, perhaps like Tony,
personally would like to know why the these IA64 systems break for
such a simple operation such as writing some base registers with
values we've probed already.
