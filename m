From: Robin Holt <holt@sgi.com>
Date: Mon, 17 Mar 2008 12:24:48 +0000
Subject: Re: [Patch 3/3] Allocate mca/init stacks as part of per_node
Message-Id: <20080317122448.GA18194@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080213175520.786006915@attica.americas.sgi.com>
In-Reply-To: <20080213175520.786006915@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 14, 2008 at 04:56:26PM -0700, Luck, Tony wrote:
> Perhaps we should leave mca.c using alloc_pages_node()
> for cpu!=0 and just have the mm/{contig.c,discontig.c}
> do a pre-allocation for cpu0 only.  In contig.c you'd
> just use the !SMP version of alloc_mca_data() for all
> cases.  Changes to discontig.c are left as an exercise
> to the reader.  Patch for mca.c looks like this:

I fixed up the -V7 patch as, what I intended to be, -V8 RFC, but I
rushed the send.  Could you test that patch instead?  It does keep the
mca stacks being allocated by the early arch init instead of mca.c.

Thanks,
Robin
