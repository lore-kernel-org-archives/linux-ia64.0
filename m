From: Dean Nelson <dcn@sgi.com>
Date: Wed, 26 Mar 2008 22:25:48 +0000
Subject: Re: [Patch 0/5] prepare XPC and XPNET to support SGI UV -v3
Message-Id: <20080326222548.GF31138@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080326215807.GF31340@sgi.com>
In-Reply-To: <20080326215807.GF31340@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jes@sgi.com, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, Mar 26, 2008 at 04:58:07PM -0500, Dean Nelson wrote:
> This set of five patches moves XPC and XPNET to drivers/misc/xp in preparation
> for enabling X86_64 support.
> 
> I discovered that the previous versions of this patch were missing the
> replacement of kernel_thread() by kthread_run() and the elimination of
> daemonize().

It looks like patches 3 and 4 of this patchset are too large to be
accepted by the linux-ia64 mailing list (whereas they both do appear
on the linux-kernel mailing list).

  -rw-r--r-- 1 dcn os1 204460 2008-03-26 16:36 generic-xp	<<< [Patch 3/5]
  -rw-r--r-- 1 dcn os1 163339 2008-03-26 16:36 Lindent		<<< [Patch 4/5]

So what do I do about them? I'm assuming I need to re-submit the patchset
with these two large patches broken up into multiple smaller patches?
What's the max patch size accepted by linux_ia64 mailing list?

Thanks,
Dean

