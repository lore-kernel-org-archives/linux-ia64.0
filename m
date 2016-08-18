From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 18 Aug 2016 15:14:57 +0000
Subject: Re: [PATCH 1/2] ia64: macro-ize ia64_done_with_exception in asm/uaccess.h
Message-Id: <20160818151457.GC25747@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160816151443.31082-1-paul.gortmaker@windriver.com>
 <20160816151443.31082-2-paul.gortmaker@windriver.com>
 <20160817171546.GD2356@ZenIV.linux.org.uk>
In-Reply-To: <20160817171546.GD2356@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

[Re: [PATCH 1/2] ia64: macro-ize ia64_done_with_exception in asm/uaccess.h] On 17/08/2016 (Wed 18:15) Al Viro wrote:

> On Tue, Aug 16, 2016 at 11:14:42AM -0400, Paul Gortmaker wrote:
> > Most of the other C content in this file is already implemented
> > in macro form.  Doing the same for this function will allow us
> > to get rid of the duplicated search_exception_tables prototype.
> > We will bring it in as required via <linux/extable.h> inclusion.
> 
> What is it doing in uaccess.h in the first place?  ia64_done_with_exception()
> is used only in the guts of arch/ia64 (2 in kernel, 1 in mm), so why dump it
> into a widely-used header?

Looking at arm and alpha, it seems there are other arch that have
exception stuff in their own arch specific uaccess.h file, so I'm
guessing it got there in ia64 just by happenstance of copying existing
implementations.

THere is a precedent for arch specific asm/exception.h -- we could
create one for ia64 and move the chunks over there if folks thought that
was worthwhile I suppose.

Paul.
--
