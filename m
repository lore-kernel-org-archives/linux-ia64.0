From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 14 Jan 2004 22:29:12 +0000
Subject: RE: Limit hash table size
Message-Id: <B05667366EE6204181EABE9C1B1C0EB580245B@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB5802441@scsmsx401.sc.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB5802441@scsmsx401.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Manfred Spraul wrote:
> What about making the limit configurable with a boot time
> parameter? If someone uses a 512 GB ppc64 as an nfs server,
> he might want a 2 GB inode hash.

I'm sorry, this code won't have any effect beyond MAX_ORDER defined for
each architecture.  It's not possible to get 2GB hash table on PPC64
since MAX_ORDER is defined at 13 so far for PPC64, which means a 16MB
absolute upper limit enforced by the page allocator.

- Ken
