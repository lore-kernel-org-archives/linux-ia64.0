From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Wed, 17 Aug 2016 17:15:46 +0000
Subject: Re: [PATCH 1/2] ia64: macro-ize ia64_done_with_exception in asm/uaccess.h
Message-Id: <20160817171546.GD2356@ZenIV.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160816151443.31082-1-paul.gortmaker@windriver.com>
 <20160816151443.31082-2-paul.gortmaker@windriver.com>
In-Reply-To: <20160816151443.31082-2-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Tue, Aug 16, 2016 at 11:14:42AM -0400, Paul Gortmaker wrote:
> Most of the other C content in this file is already implemented
> in macro form.  Doing the same for this function will allow us
> to get rid of the duplicated search_exception_tables prototype.
> We will bring it in as required via <linux/extable.h> inclusion.

What is it doing in uaccess.h in the first place?  ia64_done_with_exception()
is used only in the guts of arch/ia64 (2 in kernel, 1 in mm), so why dump it
into a widely-used header?
