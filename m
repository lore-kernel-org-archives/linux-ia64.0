From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 27 Feb 2004 17:33:44 +0000
Subject: Re: [Lse-tech] fix zonelist ordering for NUMA
Message-Id: <20040227173344.GC4067@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1077652196.26287.6.camel@arrakis>
In-Reply-To: <1077652196.26287.6.camel@arrakis>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 27, 2004 at 09:19:58PM +0900, j-nomura@ce.jp.nec.com wrote:
> I updated the patch.
> This version of build_zonelists() is NUMA-specific one.
> It will handle the situation Erich pointed out better.

This patch looks great to me.  Care to send it on to Andrew for
inclusion into his tree?

Thanks,
Jesse
