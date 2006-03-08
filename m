From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 08 Mar 2006 22:32:05 +0000
Subject: RE: Fix race in the accessed/dirty bit handlers
Message-Id: <Pine.LNX.4.64.0603081426040.10041@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 8 Mar 2006, Luck, Tony wrote:

> >Page migration is particular suitable for the creation of this race since
> >it needs to remove and restore page table entries.
> 
> I'm trying to understand why we haven't seen this problem before page
> migration was invented.  Surely in the swapout case we have the same
> situation ... swapper does "*pte = 0 ... ptc" to zap the pte and nuke
> the TLB (in that order), but there is a window in between where the
> process might try to update the accessed/dirty bits.
> 
> Have we just been lucky?

Yes. The window is very small. The zapping must happen between the 
generation of the accessed/dirty fault and the cmpxchg in the 
dirty/accessed bit handlers. It seems also that most HPC machines do not 
use swap making it highly unlikely to encounter this race. The other cases 
where this could occur are probably even rarer.

> Is the window much wider for the process migration case?

Process migration must unmap all ptes in order to migrate a page. The 
testcase here was a loop that continually moves a set of processes 
(aim7) in order to stress page migration and correspondingly the page 
table handling of the VM.
