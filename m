From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 18 Jan 2018 19:02:43 +0000
Subject: Re: [PATCH] ia64: Rewrite atomic_add and atomic_sub
Message-Id: <20180118190242.h76tueqa474zeo6o@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180118183953.29257-1-willy@infradead.org>
In-Reply-To: <20180118183953.29257-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 18, 2018 at 10:39:53AM -0800, Matthew Wilcox wrote:
> +	int __i = (i);							\
> +	static const int __ia64_atomic_p = __ia64_atomic_const(i);	\
> +	__ia64_atomic_p ? ia64_fetch_and_add(__i, &(v)->counter) :	\
> +				ia64_atomic_add(__i, v);		\

"static"?  Is that safe? What if we are executing
atomic_add on multiple cpus at the same time?

Do all those "static" declarations resolve to separate
memory locations per call site?

-Tony
