From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 23 Jul 2004 05:39:07 +0000
Subject: Re: [PATCH] - Initialize sched domain table
Message-Id: <20040723053907.GB13215@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040723010257.GA27350@sgi.com>
In-Reply-To: <20040723010257.GA27350@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jack Steiner <steiner@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>


* Jack Steiner <steiner@sgi.com> wrote:

> Here is a trivial patch that is required to boot the latest 2.6.7 tree 
> on the SGI 512p system.
> 
> 	Initial the busy_factor in the sched_domain_init table.
> 	Otherwise, booting hangs doing excessive load balance
> 	operations.
> 
> 	Signed-off-by: Jack Steiner <steiner@sgi.com>

looks good.

Signed-off-by: Ingo Molnar <mingo@elte.hu>

	Ingo
