From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 06 Feb 2004 00:10:35 +0000
Subject: RE: Limit hash table size
Message-Id: <B05667366EE6204181EABE9C1B1C0EB58024C3@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB5802441@scsmsx401.sc.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB5802441@scsmsx401.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Andrew,

Will you merge the changes in the network area first while I'm working
on the solution suggested here for inode and dentry? The 2GB tcp hash is
the biggest problem for us right now.

- Ken


-----Original Message-----
From: Andrew Morton [mailto:akpm@osdl.org] 
Sent: Thursday, February 05, 2004 3:58 PM
To: Chen, Kenneth W
Cc: linux-kernel@vger.kernel.org; linux-ia64@vger.kernel.org
Subject: Re: Limit hash table size

Ken, I remain unhappy with this patch.  If a big box has 500 million
dentries or inodes in cache (is possible), those hash chains will be
more
than 200 entries long on average.  It will be very slow.

We need to do something smarter.  At least, for machines which do not
have
the ia64 proliferation-of-zones problem.

Maybe we should leave the sizing of these tables as-is, and add some
hook
which allows the architecture to scale them back.
