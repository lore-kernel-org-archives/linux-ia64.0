From: William Lee Irwin III <wli@holomorphy.com>
Date: Thu, 05 Aug 2004 13:36:37 +0000
Subject: Re: Hugetlb demanding paging for -mm tree
Message-Id: <20040805133637.GG14358@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408051329.i75DT3Y26431@unix-os.sc.intel.com>
In-Reply-To: <200408051329.i75DT3Y26431@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Seth, Rohit" <rohit.seth@intel.com>

On Thu, Aug 05, 2004 at 06:29:02AM -0700, Chen, Kenneth W wrote:
> Dusted it off from 3 month ago.  This time re-diffed against 2.6.8-rc3-mm1.
> One big change compare to previous release is this patch should work for
> ALL arch that supports hugetlb page.  I have tested it on ia64 and x86.
> For x86, tested with no highmem config, 4G highmem config and PAE config.
> I have not tested it on sh, sparc64 and ppc64, but I have no reason to
> believe that this feature won't work on these arches.
> Patches are broken into two pieces.  But they should be applied together
> to have correct functionality for hugetlb demand paging.
> 00.demandpaging.patch - core hugetlb demand paging
> 01.overcommit.patch   - hugetlbfs strict overcommit accounting.
> Testing and comments are welcome.  Thanks.
> - Ken Chen

Could you resend as plaintext?


-- wli
