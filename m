From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 03 Mar 2005 05:48:38 +0000
Subject: Re: Page fault scalability patch V18: Drop first acquisition of ptl
Message-Id: <Pine.LNX.4.58.0503022144370.4272@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503011947001.25441@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0503011951100.25441@schroedinger.engr.sgi.com>
 <20050302174507.7991af94.akpm@osdl.org> <Pine.LNX.4.58.0503021803510.3080@schroedinger.engr.sgi.com>
 <20050302185508.4cd2f618.akpm@osdl.org> <Pine.LNX.4.58.0503021856380.3365@schroedinger.engr.sgi.com>
 <20050302201425.2b994195.akpm@osdl.org> <Pine.LNX.4.58.0503022021150.3816@schroedinger.engr.sgi.com>
 <20050302205612.451d220b.akpm@osdl.org> <Pine.LNX.4.58.0503022110280.4083@schroedinger.engr.sgi.com>
 <20050302213735.65be2db1.akpm@osdl.org>
In-Reply-To: <20050302213735.65be2db1.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 2 Mar 2005, Andrew Morton wrote:

> > There should be no change to these arches
>
> But we must at least confirm that these architectures can make these
> changes in the future.  If they make no changes then they haven't
> benefitted from the patch.  And the patch must be suitable for all
> architectures which might hit this scalability problem.
>
> > Could we at least get the first two patches in? I can then gradually
> > address the other issues piece by piece.
>
> The atomic ops patch should be coupled with the main patch series.  The mm
> counter one we could sneak in beforehand, I guess.

The atomic ops patch basically just avoids doing a pte_clear and then
setting the pte for archs that define CONFIG_ATOMIC_TABLE_OPS. This is
unecessary on ia64 and ia32 AFAIK.

>
> > The necessary more sweeping design change can be found at
> >
> > http://marc.theaimsgroup.com/?l=linux-kernel&m0922543030922&w=2
> >
> > but these may be a long way off.
>
> Yes, that seemed sensible, although it may not work out to be as clean as
> it appears.

Of course. But at least we would like to start as clean as possible.

> But how would that work allow us to address page_table_lock scalability
> problems?

Because the actual locking method is abstracted in a transaction
(idea by Nick Piggins, I just tried to make it cleaner). The arch may use
pte locking, pmd locking, atomic ops or whatever to provide
synchronization for page table operations.


