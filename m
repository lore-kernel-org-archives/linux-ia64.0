From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 08 Mar 2006 15:33:06 +0000
Subject: Re: Fix race in the accessed/dirty bit handlers
Message-Id: <Pine.LNX.4.64.0603080731240.5074@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 8 Mar 2006, Robin Holt wrote:

> Are you sure this does not lead to a data integrity issue.  What if we
> have a clean writable page.  If we get started on the dirty handler and
> the pte gets zapped from under us, the page would not get marked as dirty
> (pte had not gotten updated yet) and the process would continue running.

No the process would not continue running. The page is not present and 
therefore the page fault handler gets involved next to get the page back. 

The page fault handler gets invoked with the write flag set. So it 
will bring back the page and mark it dirty. Then it will return to the 
process which will perform the write operation.
