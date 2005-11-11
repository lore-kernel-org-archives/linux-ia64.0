From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 11 Nov 2005 02:06:43 +0000
Subject: RE: [Patch 1/1] 4-level page tables v4.
Message-Id: <200511110206.jAB26hg22724@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
In-Reply-To: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote on Thursday, November 10, 2005 5:20 PM
> Here is another go.  I removed the p9 check.  It all fits fairly
> nicely under a #ifdef.

Oh, p9 is introduced to remove some of the #ifdef, which is what
people are grumbling about for readability and maintainability.
I thought it's a neat idea.  Apparently not so from your view?

- Ken



