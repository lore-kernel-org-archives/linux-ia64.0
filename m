From: Christoph Hellwig <hch@infradead.org>
Date: Sun, 11 Jul 2004 10:22:34 +0000
Subject: Re: serious performance regression due to NX patch
Message-Id: <20040711102234.GA11534@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407100528.i6A5SF8h020094@napali.hpl.hp.com> <Pine.LNX.4.58.0407110437310.26065@devserv.devel.redhat.com> <Pine.LNX.4.58.0407110536130.2248@devserv.devel.redhat.com> <Pine.LNX.4.58.0407110550340.4229@devserv.devel.redhat.com>
In-Reply-To: <Pine.LNX.4.58.0407110550340.4229@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@redhat.com>
Cc: davidm@hpl.hp.com, suresh.b.siddha@intel.com, jun.nakajima@intel.com, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Jul 11, 2004 at 05:52:59AM -0400, Ingo Molnar wrote:
> 
> On Sun, 11 Jul 2004, Ingo Molnar wrote:
> 
> > > ok, agreed. I'll check that it still does the right thing on x86.
> > 
> > it doesnt seem to do the right thing for !PT_GNU_STACK applications on 
> > x86:
> 
> how about the patch below? This way we recognize the fact that x86 didnt
> have any executability check previously at the point where we discover
> that it's a 'legacy' binary.

Please don't add per-architecture ifdefs to generic code.  And I'm pretty
sure there's quite a few more architectures with the same issue.

