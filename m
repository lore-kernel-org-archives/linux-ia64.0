From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 23 Feb 2004 16:19:29 +0000
Subject: RE: HUGEPAGE SIZE a boottime option
Message-Id: <B05667366EE6204181EABE9C1B1C0EB501F2AB08@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220010731.GA28820@sgi.com>
In-Reply-To: <20040220010731.GA28820@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 20, 2004 at 11:36:38AM -0800, Seth, Rohit wrote:

> As long as there are only two supported page sizes (PAGE_SIZE and
> HPAGE_SIZE), it is possible to achieve the boot time configuration
> of HUGE_PAGE_SIZE without needing to patch the kernel (and possibly
> better packing the vhpt fault handler code).


On Sat, February 21, 2004 at 9:28 PM, Chris Wedgwood wrote:

> Jack's code doesn't have this limitation.  IMO it's a more
> sane way to go.  Why should people be restricted to a limited
> set (two) of hugepage sizes?  This seems especially important
> for vendor kernels where people want to use the same kernel
> across a variety of different machines.


It's probably a misunderstanding.  We are talking about run time
user page size, and you probably referring to huge page size that
user wants to specify at boot time.  These are two totally
different things.

- Ken
