From: Jes Sorensen <jes@sgi.com>
Date: Tue, 24 Jan 2006 09:14:28 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <43D5EFF4.9090206@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> Thinking about this a bit more, wouldn't it be better to do this
> work in the rebalance code that is making the decision to move
> the process.  The earlier argument that this would sometimes
> waste time because the process might not actually move doesn't
> sound so strong ... we context switch frequently, we move processes
> rarely.  Doing some work that may be wasted in the rare path sounds
> better than always doing work in the common path.

Alternatively one could make platform_switch_from() a wrapper around
a function pointer that is only set when in use. Then it would be a
load and a compare and the rest will be predicated away on non SN
hardware in the generic kernel.

Cheers,
Jes
