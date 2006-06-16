From: Andi Kleen <ak@suse.de>
Date: Fri, 16 Jun 2006 16:24:52 +0000
Subject: Re: FOR REVIEW: New x86-64 vsyscall vgetcpu()
Message-Id: <200606161824.52620.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606140942.31150.ak@suse.de> <200606161737.06132.ak@suse.de> <20060616155804.GN3823@sunsite.mff.cuni.cz>
In-Reply-To: <20060616155804.GN3823@sunsite.mff.cuni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jakub Jelinek <jakub@redhat.com>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, discuss@x86-64.org, linux-kernel@vger.kernel.org, libc-alpha@sourceware.org, vojtech@suse.cz, linux-ia64@vger.kernel.org

On Friday 16 June 2006 17:58, Jakub Jelinek wrote:
> On Fri, Jun 16, 2006 at 05:37:06PM +0200, Andi Kleen wrote:
> > On Friday 16 June 2006 17:31, Zoltan Menyhart wrote:
> > > Andi Kleen wrote:
> > > 
> > > > That is not how user space TLS works. It usually has a base a register.
> > > 
> > > Can you please give me a real life (simplified) example?
> > 
> > On x86-64 it's just %fs:offset. gcc is a bit dumb on this and usually
> > loads the base address from %fs:0 first.
> 
> GCC is not dumb, unless you force it with -mno-tls-direct-seg-refs.
> Guess you are bitten by SUSE GCC hack which makes -mno-tls-direct-seg-refs
> the default (especially on x86-64 it is a really bad idea).

I apparently got indeed.

I wonder why it happened on x86-64 though - i thought there were no negative
offsets on x86-64 TLS.

-Andi
