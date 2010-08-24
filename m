From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 24 Aug 2010 22:23:52 +0000
Subject: Re: [PATCH] hide guard page for stacks that grow upwards
Message-Id: <AANLkTin5mxbyH9BOcrGAW2nFiDBOeUE8=HsBR8U=x3bc@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4c74419664798b8c9@agluck-desktop.sc.intel.com>
In-Reply-To: <4c74419664798b8c9@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, Aug 24, 2010 at 3:03 PM, Luck, Tony <tony.luck@intel.com> wrote:
>
> This looks useful too ... but I can't see where the code is that
> made vm_start be PAGE_SIZE lower to begin with. I'd expect to have
> to make a matching change to make vm_end PAGE_SIZE higher for the
> VM_GROWSUP areas.

That's the fault path - the very check_stack_guard_page() logic itself.

In other words, nowhere do we _explicitly_ make the stack larger by
one page, but nowhere do we explicitly size the stack in the first
place! The stack grows by being populated, and every time a new page
is populated, check_stack_guard_page() will have expanded the stack
vma by one extra page.

                   Linus
