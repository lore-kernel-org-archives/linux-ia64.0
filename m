From: Matthew Wilcox <willy@infradead.org>
Date: Fri, 13 Apr 2018 20:21:08 +0000
Subject: Re: [PATCH 00/32] docs/vm: convert to ReST format
Message-Id: <20180413202108.GA30271@bombadil.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180329154607.3d8bda75@lwn.net>
 <20180401063857.GA3357@rapoport-lnx>
 <20180413135551.0e6d1b12@lwn.net>
In-Reply-To: <20180413135551.0e6d1b12@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jonathan Corbet <corbet@lwn.net>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Apr 13, 2018 at 01:55:51PM -0600, Jonathan Corbet wrote:
> > I believe that keeping the mm docs together will give better visibility of
> > what (little) mm documentation we have and will make the updates easier.
> > The documents that fit well into a certain topic could be linked there. For
> > instance:
> 
> ...but this sounds like just the opposite...?  
> 
> I've had this conversation with folks in a number of subsystems.
> Everybody wants to keep their documentation together in one place - it's
> easier for the developers after all.  But for the readers I think it's
> objectively worse.  It perpetuates the mess that Documentation/ is, and
> forces readers to go digging through all kinds of inappropriate material
> in the hope of finding something that tells them what they need to know.
> 
> So I would *really* like to split the documentation by audience, as has
> been done for a number of other kernel subsystems (and eventually all, I
> hope).
> 
> I can go ahead and apply the RST conversion, that seems like a step in
> the right direction regardless.  But I sure hope we don't really have to
> keep it as an unorganized jumble of stuff...

I've started on Documentation/core-api/memory.rst which covers just
memory allocation.  So far it has the Overview and GFP flags sections
written and an outline for 'The slab allocator', 'The page allocator',
'The vmalloc allocator' and 'The page_frag allocator'.  And typing this
up, I realise we need a 'The percpu allocator'.  I'm thinking that this
is *not* the right document for the DMA memory allocators (although it
should link to that documentation).

I suspect the existing Documentation/vm/ should probably stay as an
unorganised jumble of stuff.  Developers mostly talking to other MM
developers.  Stuff that people outside the MM fraternity should know
about needs to be centrally documented.  By all means convert it to
ReST ... I don't much care, and it may make it easier to steal bits
or link to it from the organised documentation.
