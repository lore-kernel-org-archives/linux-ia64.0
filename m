From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 29 Mar 2006 07:44:05 +0000
Subject: RE: Prefetch mmap_sem in ia64_do_page_fault()
Message-Id: <200603290743.k2T7hKg04228@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603282251410.20180@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603282251410.20180@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote on Tuesday, March 28, 2006 11:32 PM
> Christoph Lameter wrote on Tuesday, March 28, 2006 11:16 PM
> > 
> > I saw David Mosberger's patch from last year
> > 
> > and it seems that he implemented fast handling of these NULL cases?
> 
> I know about that patch and I'm referring in the context of that commit:
> 
> ld8.s r1=[r0]      - immediate nat generation, no fault
> lfetch.fault [r0]  - generate nat page consumption because lfetch is not
>                      considered as a speculative access.
> 
> The nat page consumption fault handler should be rather quick, though cpu
> still have to fault into the handler, muck around with ipsr.ed bit and
> then rfi.  What I'm saying is there is an even *faster* way of doing
> prefetch.

One other caveat with this is that if you have a tlb miss on mm->mmap_sem,
it won't prefetch anything because alt_dtlb_miss handler will nuke the
ld8.s or lfetch instruction :-(

- Ken
