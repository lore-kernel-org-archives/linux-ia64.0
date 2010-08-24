From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 24 Aug 2010 18:04:17 +0000
Subject: RE: [PATCH] guard page for stacks that grow upwards
Message-Id: <987664A83D2D224EAE907B061CE93D53015D8131A1@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4c73f3ed34663af90@agluck-desktop.sc.intel.com>
 <AANLkTi=-JRUFH08TYNhB7TyN=YscnNbqwtZ_BwcwKJPS@mail.gmail.com>
In-Reply-To: <AANLkTi=-JRUFH08TYNhB7TyN=YscnNbqwtZ_BwcwKJPS@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

>  - that "else" looks wrong. At least conceptually, both could happen -
> the code should be entirely able to handle a segment that expands both
> ways (which is something that ia64 could do: stack one way, register
> spills etc other, all in just one happy vma). I guess we don't set it
> up that way now, but the "else" just annoys my sense of aesthetics.
> It's an extra four letters that don't add value - just takes it away.

Conceptually yes we could - I don't suppose we ever will as keeping
separate vmas for stack and RSE stack defends against underflow in
a program that has totally messed up.  But I can save 4 bytes of
source code and drop the "else".

> - The "address = PAGE_ALIGN(address + 1);" thing is just ugly.
> Wouldn't it be nicer to just move the earlier
>
>  address &= PAGE_MASK

This mask might be redundant ... I didn't look at the call
sequence, but I've observed that "address" happens to be page
aligned in all my tests.

> back outside the conditionals (and keep the original conditional the
> way it was - you only changed it for that bogus "else" case anyway),
> and then do
>
>  if (address + PAGE_SIZE = vma->vm_end)
>
> rather than have "PAGE_ALIGN(address + 1)" as yet another way of
> aligning the address just right.

Yes, that works too.

Coding revised version now.

-Tony
