From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 24 Aug 2010 16:53:12 +0000
Subject: Re: [PATCH] guard page for stacks that grow upwards
Message-Id: <AANLkTinQ_0zGJnPHw7AMJ+q+oo4nmA9Z4irw8dqRH9S8@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4c73f3ed34663af90@agluck-desktop.sc.intel.com>
In-Reply-To: <4c73f3ed34663af90@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, Aug 24, 2010 at 9:31 AM, Luck, Tony <tony.luck@intel.com> wrote:
>
> Updated to match the new code - still not tested on pa-risc.

But the ia64 grows-up case is tested?

> The #ifdefs are ugly - suggestions welcome on how to make
> the code prettier.

One thing I've considered is to get rid of the CONFIG_STACK_GROWSUP
crap entirely in code, and instead just make the VM_GROWSUP #define be
0 for architectures that don't want it. The compiler should then just
automatically remove all the code that says

   if (vma->vm_flags & VM_GROWSUP) {
     ...

and the code would look more straightforward. Hmm?

                    Linus
