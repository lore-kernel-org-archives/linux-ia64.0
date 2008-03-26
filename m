From: David Miller <davem@davemloft.net>
Date: Wed, 26 Mar 2008 04:36:02 +0000
Subject: Re: larger default page sizes...
Message-Id: <20080325.213602.193698359.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea430803251734u70f199w10951bc4f0db6262@mail.gmail.com>
	<87lk465mks.wl%peter@chubb.wattle.id.au>
	<47E9CE00.7060106@fc.hp.com>
In-Reply-To: <47E9CE00.7060106@fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jsm@fc.hp.com
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: John Marvin <jsm@fc.hp.com>
Date: Tue, 25 Mar 2008 22:16:00 -0600

> 1) There was no easy way of determining what size the long format vhpt cache 
> should be automatically, and changing it dynamically would be too painful. 
> Different workloads performed better with different size vhpt caches.

This is exactly what sparc64 does btw, dynamic TLB miss hash table
sizing based upon task RSS
