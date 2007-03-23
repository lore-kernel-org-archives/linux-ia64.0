From: "Tony Luck" <tony.luck@intel.com>
Date: Fri, 23 Mar 2007 04:56:03 +0000
Subject: Re: [PATCH][2/2] double stack limit (rfc)
Message-Id: <12c511ca0703222156u3cc09833rec636b47ad156029@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070323122129.555a87fd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070323122129.555a87fd.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "dmosberger@gmail.com" <dmosberger@gmail.com>, surinder.kumar@oracle.com, LKML <linux-kernel@vger.kernel.org>

On 3/22/07, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> I hear some people says that "When I set stack-size-limit to 32M,
> I want to use 32M of memory stack..." and register-stack expansion can
> fail because stack is used up by memory-stack.

An interesting dilemma.  If you apply this patch though, you might
get someone complain that they set the stack limit to 32M, but
execution continued as the program ran all the way to 64M!

Possibly you might argue that each of the memory stack and the
RBS stack should be allowed to grow to the stacklimit ... in which
case you'd need a more invasive patch that made separate vma
for each of the stack and the RBS stack, and checked at fault
time each would be allowed to grow to the stack limit.  But I'm
not sure that I like that ... ia64 happens to split different objects
in the stack between the RBS and the memory stack depending
on whether they happen to be allocated by the compiler to
stack registers (r32-r127) or to actual memory locations.  Both
types of allocation contribute to the total "stack" size of the
process so the existing behaivour of keeping the sum of the
size of the RBS stack and the memory stack below the
stack limit seems quite reasonable.  I'm willing to listen to
opposing arguments though.

-Tony
