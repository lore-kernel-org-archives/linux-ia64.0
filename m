From: Andrew Morton <akpm@osdl.org>
Date: Thu, 03 Mar 2005 05:37:35 +0000
Subject: Re: Page fault scalability patch V18: Drop first acquisition of ptl
Message-Id: <20050302213735.65be2db1.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503011947001.25441@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0503011951100.25441@schroedinger.engr.sgi.com>
	<20050302174507.7991af94.akpm@osdl.org>
	<Pine.LNX.4.58.0503021803510.3080@schroedinger.engr.sgi.com>
	<20050302185508.4cd2f618.akpm@osdl.org>
	<Pine.LNX.4.58.0503021856380.3365@schroedinger.engr.sgi.com>
	<20050302201425.2b994195.akpm@osdl.org>
	<Pine.LNX.4.58.0503022021150.3816@schroedinger.engr.sgi.com>
	<20050302205612.451d220b.akpm@osdl.org>
	<Pine.LNX.4.58.0503022110280.4083@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503022110280.4083@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter <clameter@sgi.com> wrote:
>
> On Wed, 2 Mar 2005, Andrew Morton wrote:
> 
> > Have the ppc64 and sparc64 people reviewed and acked the change?  (Not a
> > facetious question - I just haven't been following the saga sufficiently
> > closely to remember).
> 
> There should be no change to these arches

But we must at least confirm that these architectures can make these
changes in the future.  If they make no changes then they haven't
benefitted from the patch.  And the patch must be suitable for all
architectures which might hit this scalability problem.

> > > Because if a pte is locked it should not be used.
> >
> > Confused.  Why not just spin on the lock in the normal manner?
> 
> I thought you wanted to lock the pte? This is realized through a lock bit
> in the pte. If that lock bit is set one should not use the pte. Otherwise
> the lock is bypassed. Or are you proposing a write lock only?

I was suggesting a lock in (or associated with) the pageframe of the page
which holds the pte.  That's just a convenient way of hashing the locking. 
Probably that's not much different from the atomic pte ops.

> > If the other relvant architecture people say "we can use this" then perhaps
> > we should grin and bear it.  But one does wonder whether some more sweeping
> > design change is needed.
> 
> Could we at least get the first two patches in? I can then gradually
> address the other issues piece by piece.

The atomic ops patch should be coupled with the main patch series.  The mm
counter one we could sneak in beforehand, I guess.

> The necessary more sweeping design change can be found at
> 
> http://marc.theaimsgroup.com/?l=linux-kernel&m0922543030922&w=2
> 
> but these may be a long way off.

Yes, that seemed sensible, although it may not work out to be as clean as
it appears.

But how would that work allow us to address page_table_lock scalability
problems?
