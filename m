From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 08 Mar 2006 21:59:03 +0000
Subject: RE: Fix race in the accessed/dirty bit handlers
Message-Id: <200603082159.k28Lx3g12281@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote on Wednesday, March 08, 2006 7:33 AM
> On Wed, 8 Mar 2006, Robin Holt wrote:
> > Are you sure this does not lead to a data integrity issue.  What if we
> > have a clean writable page.  If we get started on the dirty handler and
> > the pte gets zapped from under us, the page would not get marked as dirty
> > (pte had not gotten updated yet) and the process would continue running.
> 
> No the process would not continue running. The page is not present and 
> therefore the page fault handler gets involved next to get the page back. 
> 
> The page fault handler gets invoked with the write flag set. So it 
> will bring back the page and mark it dirty. Then it will return to the 
> process which will perform the write operation.

What happens to a scenario where you zap the pte right after dirty bit
handler just finished.  Won't you lost that "dirty" information?

- Ken

