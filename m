From: "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com>
Date: Thu, 21 Feb 2002 21:09:30 +0000
Subject: [Linux-ia64] determining read or write on a page fault
Message-Id: <marc-linux-ia64-105590701905163@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We are writing software that handles page faults on an Itanium system, and
so have registered a SIGSEGV
handler.  We think we know how to determine the address being referenced,
but don't know how to determine
whether the access was a read or a write.

We believe that the handler entry point should be:

void
segv_handler(
        int                  sig,
       siginfo_t *sip, 
        struct sigcontext *scp)

and the address of the access therefore should be:

((caddr_t)sip->si_addr)

but how do we determine READ vs WRITE?

In IA-32 linux, we could check the PF_ERR bit.  Is there an equivalent for
IA-64?

Thanks

Naveen Neelakantam and Jay Hoeflinger


Jay Hoeflinger, jay.p.hoeflinger@intel.com
KAI Software, A Division of Intel Americas, Inc., http://www.kai.com
Phone 217/356-2288, Direct 217/356-5052 x 140, Fax 217/356-5199



