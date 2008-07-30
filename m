From: David Miller <davem@davemloft.net>
Date: Wed, 30 Jul 2008 22:18:26 +0000
Subject: Re: [Patch] fix ia64 build failure when CONFIG_SFC=m
Message-Id: <20080730.151826.58205352.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080729174839.GG10471@solarflare.com>
	<20080729.140040.72089155.davem@davemloft.net>
	<20080730133527.GI10471@solarflare.com>
In-Reply-To: <20080730133527.GI10471@solarflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bhutchings@solarflare.com
Cc: tony.luck@intel.com, jgarzik@redhat.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, netdev@vger.kernel.org, matthew@wil.cx, holt@sgi.com, linux-net-drivers@solarflare.com

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 30 Jul 2008 14:35:29 +0100

> So far as I can see, hardly anyone is doing routing at 10G speeds on Linux.
> If they were, the horrible interaction with LRO would presumably have been
> found and fixed earlier.

This assumes a precise intersection between those doing 10G routing
and their using chips with LRO capable drivers.

All of the 10G equipment I have here and do testing on use drivers
that lack LRO support.
