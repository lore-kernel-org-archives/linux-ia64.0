From: Martin Hicks <mort@bork.org>
Date: Fri, 05 Aug 2005 12:46:19 +0000
Subject: Re: IA64 Spinlock optimizations
Message-Id: <20050805124619.GN26803@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508042031300.3346@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508042031300.3346@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Thu, Aug 04, 2005 at 08:33:33PM -0700, Christoph Lameter wrote:
>  
> +static inline void _raw_write_unlock(rwlock_t *x)
> +{
> +	barrier();
> +	x-&gt;write_lock = 0;
         ^^^

	 Heh...html?

mh

-- 
Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE
