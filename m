From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 18 Dec 2007 23:29:19 +0000
Subject: RE: [PATCH RFC][try 2] IA64 signal : remove redundant code in setup_sigcontext()
Message-Id: <1FE6DD409037234FAB833C420AA843EC22DA39@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4744F46B.6050004@cn.fujitsu.com> <20071122033249.GM12494@parisc-linux.org>
In-Reply-To: <20071122033249.GM12494@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>, Shi Weihua <shiwh@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>> This patch removes some redundant code in the function setup_sigcontext().
>> 
>> The registers ar.ccv,b7,r14,ar.csd,ar.ssd,r2-r3 and r16-r31 are not restored 
>> in restore_sigcontext() when (flags & IA64_SC_FLAG_IN_SYSCALL) is true. 
>> So we don't need to zero those variables in setup_sigcontext().
>
> Erm, couldn't those registers contain information the process shouldn't
> see?

No, this looks safe.  setup_sigcontext() is stashing things out on the
user stack to be used by restore_sigcontext() should the application want
to return from the signal handler.  But restore_sigcontext isn't actually
in charge of putting values into machine registers, it just does the copy
back from user space to the place where the asm code will restore registers
on the way back to userland.  In this instance "restored" means "set back to
the state they had before the signal happened".  If they aren't "restored"
they'll have scratch values ... but those scratch values will have come
from the application (while it was executing the signal handler).  Not
leaked from the kernel or from some other application.

-Tony
