From: William Lee Irwin III <wli@holomorphy.com>
Date: Thu, 19 Aug 2004 03:31:27 +0000
Subject: Re: page fault fastpath patch v2: fix race conditions, stats for 8,32     and    512 cpu SMP
Message-Id: <20040819033127.GB11200@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2uexw-1Nn-1@gated-at.bofh.it> <2uCTq-2wa-55@gated-at.bofh.it> <pan.2004.08.18.23.50.13.562750@umich.edu> <20040819000151.GU11200@holomorphy.com> <Pine.GSO.4.58.0408182005080.9340@sapphire.engin.umich.edu> <20040819002038.GW11200@holomorphy.com> <Pine.LNX.4.58.0408182307400.7247@red.engin.umich.edu>
In-Reply-To: <Pine.LNX.4.58.0408182307400.7247@red.engin.umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rajesh Venkatasubramanian <vrajesh@umich.edu>
Cc: Hugh Dickins <hugh@veritas.com>, "David S. Miller" <davem@redhat.com>, raybry@sgi.com, ak@muc.de, benh@kernel.crashing.org, manfred@colorfullife.com, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 18 Aug 2004, William Lee Irwin III wrote:
>> Something like this?

On Wed, Aug 18, 2004 at 11:19:25PM -0400, Rajesh Venkatasubramanian wrote:
> Yeah, something similar... A small nitpick: page_table_lock
> nests within i_mmap_lock and anon_lock.
> do_unmap() also frees page tables first and then removes vmas from
> i_mmap (and/or) anon_vma list. Is there a reason to preserve
> this ordering ?

I don't see a reason to rearrange it. We can just as easily drop and
reacquire ->page_table_lock.


-- wli
