From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 29 Jul 2005 08:02:42 +0000
Subject: RE: Add prefetch switch stack hook in scheduler function
Message-Id: <200507290802.j6T82hg08064@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <10766.1122623142@kao2.melbourne.sgi.com>
References: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
In-Reply-To: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Keith Owens' <kaos@ocs.com.au>
Cc: 'Ingo Molnar' <mingo@elte.hu>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Keith Owens wrote on Friday, July 29, 2005 12:46 AM
> On Fri, 29 Jul 2005 00:22:43 -0700, 
> "Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
> >On ia64, we have two kernel stacks, one for outgoing task, and one for
> >incoming task.  for outgoing task, we haven't called switch_to() yet.
> >So the switch stack structure for 'current' will be allocated immediately
> >below current 'sp' pointer. For the incoming task, it was fully ctx'ed out
> >previously, so switch stack structure is immediate above kernel_stack(next).
> >It Would be beneficial to prefetch both stacks.
> 
> struct switch_stack for current is all write data, no reading is done.
> Is it worth doing prefetchw() for current?

Oh yes, very much so.  L2 is an out of order cache and it can only queue
limited amount of store operations.  With the number of stores for switch
stack structure, it will easily exceed that hardware limit.

> IOW, is there any measurable performance gain?

I don't have exact breakdown to how much contribute from prefetch the outgoing
process versus incoming process.  But I believe both contributes to perf.
gain.

- Ken


