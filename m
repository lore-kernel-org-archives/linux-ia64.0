From: Andi Kleen <ak@suse.de>
Date: Thu, 06 Jan 2005 20:06:49 +0000
Subject: Re: [PATCH] cleanup swiotlb.c a bit
Message-Id: <20050106200649.GF28889@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060945.12364.jbarnes@engr.sgi.com>
In-Reply-To: <200501060945.12364.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Well, it probably should move outside of the ia64 tree anyhow.  The
> > way x86_64 includes swiotlb.c at the moment is just absolutely gross.
> 
> kernel/swiotlb.c would make most sense, I guess?

No problem from my side, as long as whoever moves it to some other
place fixes up the x86-64 Makefile at the same time :)

-Andi
