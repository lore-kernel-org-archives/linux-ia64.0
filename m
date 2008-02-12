From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 12 Feb 2008 22:40:52 +0000
Subject: Re: [PATCH] SGI Altix mmtimer - allow larger number of timers per
Message-Id: <20080212144052.4ebb69d7.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080207213552.GA2658@sgi.com>
In-Reply-To: <20080207213552.GA2658@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 9 Feb 2008 15:49:17 -0600
Dimitri Sivanich <sivanich@sgi.com> wrote:

> +void mmtimer_add_list(struct mmtimer *n)
> +void mmtimer_set_next_timer(int nodeid)
> +void mmtimer_tasklet(unsigned long data)

These didn't need to be global.  I shall mark them static.
