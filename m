From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 29 Jul 2005 08:30:41 +0000
Subject: RE: Add prefetch switch stack hook in scheduler function
Message-Id: <200507290830.j6T8Ugg08348@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20050729070702.GA3327@elte.hu>
References: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
In-Reply-To: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Ingo Molnar' <mingo@elte.hu>
Cc: Keith Owens <kaos@ocs.com.au>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Ingo Molnar wrote on Friday, July 29, 2005 12:07 AM
> the patch below unrolls the prefetch_range() loop manually, for up to 5 
> cachelines prefetched. This patch, ontop of the 4 previous patches, 
> should generate similar code to the assembly code in your original 
> patch. The full patch-series is:

It generate slight different code because previous patch asks for a little
over 5 cache lines worth of bytes and it always go to the for loop.

