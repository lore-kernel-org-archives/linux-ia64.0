From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 04 Jan 2005 16:24:33 +0000
Subject: Re: [PATCH] - Update SN2 code for running on simulator
Message-Id: <200501040824.33474.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050104142411.GA22312@sgi.com>
In-Reply-To: <20050104142411.GA22312@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, January 4, 2005 6:24 am, Jack Steiner wrote:
> +  addr = (is_shub2() ? 0xc00000028c000000 : 0xc0000087cc000000) | ((port
> >> 2) << 12); +  if ((port >= 0x1f0 && port <= 0x1f7) || port = 0x3f6 ||
> port = 0x3f7) +   addr |= port;
>    return (void *)addr;
>   }
>  }

Can we keep the UL specifiers in there?  It helps silence sparse and is a 
little more correct.

Thanks,
Jesse
