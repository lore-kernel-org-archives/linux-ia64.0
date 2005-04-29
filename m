From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 29 Apr 2005 21:02:40 +0000
Subject: Re: [PATCH 3/3] Page Fault Scalability V20: Avoid lock for anonymous write fault
Message-Id: <20050429210240.GA14774@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050429195901.15694.28520.sendpatchset@schroedinger.engr.sgi.com> <20050429195917.15694.21053.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20050429195917.15694.21053.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Fri, Apr 29, 2005 at 12:59:17PM -0700, Christoph Lameter wrote:
> Do not use the page_table_lock in do_anonymous_page. This will significantly
> increase the parallelism in the page fault handler for SMP systems. The patch
> also modifies the definitions of _mm_counter functions so that rss and anon_rss
> become atomic (and will use atomic64_t if available).

I thought we said all architectures should provide an atomic64_t (and
given that it's not actually 64bit on 32bit architecture we should
probably rename it to atomic_long_t)

