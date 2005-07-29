From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 29 Jul 2005 08:35:58 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <20050729083558.GA7302@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050729070702.GA3327@elte.hu> <200507290830.j6T8Ugg08348@unix-os.sc.intel.com>
In-Reply-To: <200507290830.j6T8Ugg08348@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Keith Owens <kaos@ocs.com.au>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:

> Ingo Molnar wrote on Friday, July 29, 2005 12:07 AM
> > the patch below unrolls the prefetch_range() loop manually, for up to 5 
> > cachelines prefetched. This patch, ontop of the 4 previous patches, 
> > should generate similar code to the assembly code in your original 
> > patch. The full patch-series is:
> 
> It generate slight different code because previous patch asks for a little
> over 5 cache lines worth of bytes and it always go to the for loop.

ok - fix below. But i'm not that sure we want to unroll a 6-instruction 
loop, and it's getting a bit ugly. (Also, it would be nice to have a gcc 
extension for loops that says 'always unroll up to N entries'.)

	Ingo

----
unroll the prefetch loop some more.

Signed-off-by: Ingo Molnar <mingo@elte.hu>

 include/linux/prefetch.h |   16 ++++++++++++++++
 1 files changed, 16 insertions(+)

Index: linux-prefetch-task/include/linux/prefetch.h
=================================--- linux-prefetch-task.orig/include/linux/prefetch.h
+++ linux-prefetch-task/include/linux/prefetch.h
@@ -87,6 +87,14 @@ static inline void prefetch_range(void *
 		prefetch(cp + 2*PREFETCH_STRIDE);
 		prefetch(cp + 3*PREFETCH_STRIDE);
 		prefetch(cp + 4*PREFETCH_STRIDE);
+	}
+	else if (len <= 6*PREFETCH_STRIDE) {
+		prefetch(cp);
+		prefetch(cp + PREFETCH_STRIDE);
+		prefetch(cp + 2*PREFETCH_STRIDE);
+		prefetch(cp + 3*PREFETCH_STRIDE);
+		prefetch(cp + 4*PREFETCH_STRIDE);
+		prefetch(cp + 5*PREFETCH_STRIDE);
 	} else
 		for (; cp < end; cp += PREFETCH_STRIDE)
 			prefetch(cp);
@@ -125,6 +133,14 @@ static inline void prefetchw_range(void 
 		prefetchw(cp + 2*PREFETCH_STRIDE);
 		prefetchw(cp + 3*PREFETCH_STRIDE);
 		prefetchw(cp + 4*PREFETCH_STRIDE);
+	}
+	else if (len <= 6*PREFETCH_STRIDE) {
+		prefetchw(cp);
+		prefetchw(cp + PREFETCH_STRIDE);
+		prefetchw(cp + 2*PREFETCH_STRIDE);
+		prefetchw(cp + 3*PREFETCH_STRIDE);
+		prefetchw(cp + 4*PREFETCH_STRIDE);
+		prefetchw(cp + 5*PREFETCH_STRIDE);
 	} else
 		for (; cp < end; cp += PREFETCH_STRIDE)
 			prefetchw(cp);
