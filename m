From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 09 Jan 2004 19:05:12 +0000
Subject: RE: Limit hash table size
Message-Id: <B05667366EE6204181EABE9C1B1C0EB5802444@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB5802441@scsmsx401.sc.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB5802441@scsmsx401.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anton Blanchard <anton@samba.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>

Anton Blanchard wrote:

>Have you done any analysis of hash depths of large memory machines? We
>had some extremely deep pagecache hashchains in 2.4 on a 64GB machine.
>While the radix tree should fix that, whos to say we cant get into a
>similar situation with the dcache?

We don't have any data to justify any size change for x86, that was the
main reason we limit the size by page order.  


>Check out how deep some of the inode hash chains are here:
>http://www.ussg.iu.edu/hypermail/linux/kernel/0312.0/0105.html

If I read them correctly, most of the distribution is in the first 2
buckets, so it doesn't matter whether you have 100 buckets or 1 million
buckets, only first 2 are being hammered hard.  So are we wasting memory
on the buckets that are not being used?

- Ken
