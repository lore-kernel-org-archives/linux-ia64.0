From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 30 Mar 2006 02:06:07 +0000
Subject: RE: Prefetch mmap_sem in ia64_do_page_fault()
Message-Id: <Pine.LNX.4.64.0603291803040.27717@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603282251410.20180@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603282251410.20180@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 28 Mar 2006, Chen, Kenneth W wrote:

> One other caveat with this is that if you have a tlb miss on mm->mmap_sem,
> it won't prefetch anything because alt_dtlb_miss handler will nuke the
> ld8.s or lfetch instruction :-(

Still no harm done. It is likely (especially in contended situations) that 
we have the tlb already. 

Maybe we could modify the patch to prefetch the tlb somehow?


