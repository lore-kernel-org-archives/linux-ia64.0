From: Andrew Morton <akpm@osdl.org>
Date: Fri, 09 Jan 2004 09:25:07 +0000
Subject: Re: Limit hash table size
Message-Id: <20040109012507.12773323.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB5802441@scsmsx401.sc.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB5802441@scsmsx401.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

"Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
>
> The issue of exceedingly large hash tables has been discussed on the
>  mailing list a while back, but seems to slip through the cracks.
> 
>  What we found is it's not a problem for x86 (and most other
>  architectures) because __get_free_pages won't be able to get anything
>  beyond order MAX_ORDER-1 (10) which means at most those hash tables are
>  4MB each (assume 4K page size).  However, on ia64, in order to support
>  larger hugeTLB page size, the MAX_ORDER is bumped up to 18, which now
>  means a 2GB upper limits enforced by the page allocator (assume 16K page
>  size).  PPC64 is another example that bumps up MAX_ORDER.
> 
>  Last time I checked, the tcp ehash table is taking a whooping (insane!)
>  2GB on one of our large machine.  dentry and inode hash tables also take
>  considerable amount of memory.
> 
>  This patch just enforces all the hash tables to have a max order of 10,
>  which limits them down to 16MB each on ia64.  People can clean up other
>  part of table size calculation.  But minimally, this patch doesn't
>  change any hash sizes already in use on x86.

Fair enough; it's better than what we had before and Mr Networking is OK
with it ;)  I can't say that I can think of anything smarter.  Thanks.

