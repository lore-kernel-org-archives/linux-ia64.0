From: Chris Wedgwood <cw@f00f.org>
Date: Sun, 22 Feb 2004 05:27:59 +0000
Subject: Re: HUGEPAGE SIZE a boottime option
Message-Id: <20040222052759.GA14666@dingdong.cryptoapps.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220010731.GA28820@sgi.com>
In-Reply-To: <20040220010731.GA28820@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 20, 2004 at 11:36:38AM -0800, Seth, Rohit wrote:

> Ken is currently in the process of providing the support for boot
> time configuration for huge page size.

What's wrong with Jack's patch?

> As long as there are only two supported page sizes (PAGE_SIZE and
> HPAGE_SIZE), it is possible to achieve the boot time configuration
> of HUGE_PAGE_SIZE without needing to patch the kernel (and possibly
> better packing the vhpt fault handler code).  We will ship the patch
> out to the list.

Jack's code doesn't have this limitation.  IMO it's a more sane way to
go.  Why should people be restricted to a limited set (two) of
hugepage sizes?  This seems especially important for vendor kernels
where people want to use the same kernel across a variety of different
machines.


