From: Anton Blanchard <anton@samba.org>
Date: Fri, 09 Jan 2004 14:25:45 +0000
Subject: Re: Limit hash table size
Message-Id: <20040109142544.GA23038@krispykreme>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB5802441@scsmsx401.sc.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB5802441@scsmsx401.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>


Hi,

> Last time I checked, the tcp ehash table is taking a whooping (insane!)
> 2GB on one of our large machine.  dentry and inode hash tables also take
> considerable amount of memory.
> 
> This patch just enforces all the hash tables to have a max order of 10,
> which limits them down to 16MB each on ia64.  People can clean up other
> part of table size calculation.  But minimally, this patch doesn't
> change any hash sizes already in use on x86.

By limiting it by order you are crippling ppc64 compared to ia64 :)
Perhaps we should limit it by size instead.

Have you done any analysis of hash depths of large memory machines? We
had some extremely deep pagecache hashchains in 2.4 on a 64GB machine.
While the radix tree should fix that, whos to say we cant get into a
similar situation with the dcache?

Check out how deep some of the inode hash chains are here:

http://www.ussg.iu.edu/hypermail/linux/kernel/0312.0/0105.html

That was on a 64GB box from memory. Switch to the current high end,
say 512GB and those chains could become a real dogs breakfast,
especially if we limit the hashtable to 4MB.

Anton
