From: Anton Blanchard <anton@samba.org>
Date: Sun, 18 Jan 2004 14:25:14 +0000
Subject: Re: Limit hash table size
Message-Id: <20040118142514.GG6293@krispykreme>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB580245C@scsmsx401.sc.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB580245C@scsmsx401.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>


Hi,

> To address Anton's concerns on PPC64, we have revised the patch to
> enforce maximum size base on number of entry instead of page order.  So
> differences in page size/pointer size etc doesn't affect the final
> calculation.  The upper bound is capped at 2M.  All numbers on x86
> remain the same as we don't want to disturb already established and
> working number.  See patch at the end of the email.  It is diff'ed
> relative to 2.6.1-mm3 tree.

That sounds reasonable to me.

Anton
