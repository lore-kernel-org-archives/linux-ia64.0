From: Keith Owens <kaos@sgi.com>
Date: Fri, 30 Apr 2004 14:52:28 +0000
Subject: Re: BUG_ON(irqs_disabled()) in smp_call_function - cant boot
Message-Id: <3330.1083336748@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040430144454.GA8719@sgi.com>
In-Reply-To: <20040430144454.GA8719@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 30 Apr 2004 09:44:54 -0500, 
Jack Steiner <steiner@sgi.com> wrote:
>There was a BUG_ON(irqs_disabled()) recently added to
>smp_call_function(). 
>
>This check is hit during boot. Looks like there is a vfree in
>sg_add that is done with interrupts disabled. This trips the BUG_ON.
>
>The check is valid, but I wonder how many other places will trip the bug
>check.

Calling vfree() with interrupts disabled eventually leads to
smp_call_function() with interrupts disabled, which is a deadlock just
waiting to happen.

