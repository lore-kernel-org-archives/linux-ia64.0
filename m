From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Thu, 10 May 2018 01:15:16 +0000
Subject: Re: [PATCH] mm: provide a fallback for PAGE_KERNEL_RO for architectures
Message-Id: <20180510011516.GZ27853@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180428001526.22475-1-mcgrof@kernel.org>
 <20180428031810.GA14566@bombadil.infradead.org>
 <20180509010438.GM27853@wotan.suse.de>
 <20180509013935.GA8131@bombadil.infradead.org>
In-Reply-To: <20180509013935.GA8131@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, Tony Luck <tony.luck@intel.com>, arnd@arndb.de, gregkh@linuxfoundation.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Tue, May 08, 2018 at 06:39:35PM -0700, Matthew Wilcox wrote:
> On Wed, May 09, 2018 at 01:04:38AM +0000, Luis R. Rodriguez wrote:
> > On Fri, Apr 27, 2018 at 08:18:10PM -0700, Matthew Wilcox wrote:
> > > ia64: Add PAGE_KERNEL_RO and PAGE_KERNEL_EXEC
> > > 
> > > The rest of the kernel was falling back to simple PAGE_KERNEL pages; using
> > > PAGE_KERNEL_RO and PAGE_KERNEL_EXEC provide better protection against
> > > unintended writes.
> > > 
> > > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > Nice, should I queue this into my series as well?
> 
> A little reluctant to queue it without anyone having tested it.  Heck,
> I didn't even check it compiled ;-)
> 
> We used to just break architectures and let them fix it up for this kind
> of thing.

History is wonderful.

> That's not really acceptable nowadays, but I don't know how
> we get arch maintainers to fix up their ports now.

OK then in that case I'll proceed with my patches for now and just
document they don't have it. Once and folks test the patch we can
consider it.

  Luis
