From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 21 Mar 2001 19:40:55 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005323@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Consider this case
	 mutex p6, p7
{ .mib 
	 (p6) instruction that changes the unwind state
	 (p7) call that does not return
}
	 unwind directives to declare new unwind state

If p7 is true, and we try to unwind inside the call, then the return address
will point to the modified unwind state which is incorrect, because we did
not execute the p6 instruction.  To make this work, we have to subtract one
from the return address to get an address before the new unwind state is
established.

I posit that this example is more realistic and more useful than the example
which modifies b0 to optimize away a branch.

Jim

