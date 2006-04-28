From: Jes Sorensen <jes@sgi.com>
Date: Fri, 28 Apr 2006 12:49:24 +0000
Subject: Re: [PATCH] change gen_pool allocator to not touch managed memory
Message-Id: <44520F54.7010209@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <444D1A7E.mailx85W11DZZU@aqua.americas.sgi.com> <20060424181626.09966912.akpm@osdl.org> <20060425155051.GA19248@sgi.com> <444F3990.5030100@sgi.com> <20060426132803.GA30360@sgi.com> <444F78AB.6030803@sgi.com> <20060426163151.GA8037@sgi.com>
In-Reply-To: <20060426163151.GA8037@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Nelson <dcn@sgi.com>
Cc: akpm@osdl.org, tony.luck@intel.com, avolkov@varma-el.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, paulus@samba.org, holt@sgi.com

Dean Nelson wrote:
> The following patch modifies the gen_pool allocator (lib/genalloc.c) to
> utilize a bitmap scheme instead of the buddy scheme. The purpose of this
> change is to eliminate the touching of the actual memory being allocated.
> 
> Since the change modifies the interface, a change to the uncached
> allocator (arch/ia64/kernel/uncached.c) is also required.
> 
> Signed-off-by: Dean Nelson <dcn@sgi.com>

Acked-by: Jes Sorensen <jes@sgi.com>

Jes
