From: Robin Holt <holt@sgi.com>
Date: Wed, 13 Feb 2008 03:23:36 +0000
Subject: Re: [PATCH] Reduce per_cpu allocations to the minimum needed for
Message-Id: <20080213032336.GT3875@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080211175918.GO3875@sgi.com>
In-Reply-To: <20080211175918.GO3875@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I have the patch to allocate the mca area at the same time as the per_cpu
areas are allocated.  It has only been compiled and booted on an Altix.
I will config and build the other configs tomorrow evening and test boot
the defconfig on both and Altix and ZX2000.

I probably won't get those tested until tomorrow or maybe Friday.

Thanks,
Robin
