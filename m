From: David Miller <davem@davemloft.net>
Date: Thu, 26 Apr 2007 21:47:43 +0000
Subject: Re: [PATCH 2/3] ia64: remove interpolater code
Message-Id: <20070426.144743.94075709.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com>
	<20070426202702.23343.10036.sendpatchset@rambler.zko.hp.com>
	<1177620767.6031.7.camel@localhost.localdomain>
In-Reply-To: <1177620767.6031.7.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: johnstul@us.ibm.com
Cc: peter.keilty@hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, eric.whitney@hp.com

From: john stultz <johnstul@us.ibm.com>
Date: Thu, 26 Apr 2007 13:52:47 -0700

> This specific patch may need to be held off until Dave Miller pushes his
> SPARC64 GENERIC_TIME conversion (as SPARC64 currently uses the
> time_interpolator code). 
> 
> I think Dave intends to push it soon, so it shouldn't be a long wait.

Feel free to break the tree meanwhile in order to delete this,
I won't mind as I'll have it fixed as soon as I merge my
sparc tree to Linus.
