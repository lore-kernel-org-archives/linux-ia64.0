From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 03 Mar 2005 04:27:33 +0000
Subject: Re: Page fault scalability patch V18: Drop first acquisition of ptl
Message-Id: <Pine.LNX.4.58.0503022021150.3816@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503011947001.25441@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0503011951100.25441@schroedinger.engr.sgi.com>
 <20050302174507.7991af94.akpm@osdl.org> <Pine.LNX.4.58.0503021803510.3080@schroedinger.engr.sgi.com>
 <20050302185508.4cd2f618.akpm@osdl.org> <Pine.LNX.4.58.0503021856380.3365@schroedinger.engr.sgi.com>
 <20050302201425.2b994195.akpm@osdl.org>
In-Reply-To: <20050302201425.2b994195.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 2 Mar 2005, Andrew Morton wrote:

> > There have been extensive discussions on all aspects of this patch.
> > This issue was discussed in
> > http://marc.theaimsgroup.com/?t0694497200004&r=1&w=2
>
> This is a difficult, intrusive and controversial patch.  Things like the
> above should be done in a separate patch.  Not only does this aid
> maintainability, it also allows the change to be performance tested in
> isolation.

Well it would have been great if this was mentioned in the actual
discussion at the time.

> > The cmpxchg will fail if that happens.
>
> How about if someone does remap_file_pages() against that virtual address
> and that syscalls happens to pick the same physical page?  We have the same
> physical page at the same pte slot with different contents, and the cmpxchg
> will succeed.

Any mmap changes requires the mmapsem.

> > http://marc.theaimsgroup.com/?l=linux-kernel&m0272296503539&w=2
>
> Those are different cases.  I still don't see why the change is justified in
> do_swap_page().

Lets undo that then.

> > These architectures have the atomic pte's not enable.  It would require
> > them to submit a patch to activate atomic pte's for these architectures.
>
>
> But if the approach which these patches take is not suitable for these
> architectures then they have no solution to the scalability problem.  The
> machines will perform suboptimally and more (perhaps conflicting)
> development will be needed.

They can implement their own approach with the provided hooks. You could
for example use SSE / MMX for atomic 64 bit ops on i386 with PAE mode by
using the start/stop macros to deal with the floatingh point issues.

> > One
> > would have to check for the lock being active leading to significant code
> > changes.
>
> Why?

Because if a pte is locked it should not be used.

Look this is an endless discussion with new things brought up at every
corner and I have reworked the patches numerous times. Could you tell me
some step by step way that we can finally deal with this? Specify a
sequence of patches and I will submit them to you step by step.

