From: Anton Blanchard <anton@samba.org>
Date: Mon, 12 Jan 2004 13:32:24 +0000
Subject: Re: Limit hash table size
Message-Id: <20040112133224.GA7287@krispykreme>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB5802444@scsmsx401.sc.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB5802444@scsmsx401.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>


> We don't have any data to justify any size change for x86, that was the
> main reason we limit the size by page order.

Well x86 isnt very interesting here, its all the 64bit archs that will
end up with TBs of memory in the future.

> If I read them correctly, most of the distribution is in the first 2
> buckets, so it doesn't matter whether you have 100 buckets or 1 million
> buckets, only first 2 are being hammered hard.  So are we wasting memory
> on the buckets that are not being used?

But look at the horrid worst case there. My point is limiting the hash
without any data is not a good idea. In 2.4 we raised MAX_ORDER on ppc64
because we spent so much time walking pagecache chains, id hate to see
us limit the icache and dcache hash in 2.6 and end up with a similar
problem.

Why cant we do something like Andrews recent min_free_kbytes patch and
make the rate of change non linear. Just slow the increase down as we
get bigger. I agree a 2GB hashtable is pretty ludicrous, but a 4MB one
on a 512GB machine (which we sell at the moment) could be too :)

Anton
