From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 30 Oct 2003 22:16:23 +0000
Subject: Re: [patch 0/4] kernel salinfo changes
Message-Id: <marc-linux-ia64-106755236412598@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106750258117748@msgid-missing>
In-Reply-To: <marc-linux-ia64-106750258117748@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 30 October 2003 1:28 am, Keith Owens wrote:
> patch 1 - Print the header from INIT records, correct typo in sal.h.
> patch 2 - Clean up kernel salinfo state checking.
> patch 3 - Add the ability for user space salinfo to ask kernel salinfo
>           and/or the prom to decode the oem data sections of SAL records.

Thanks for splitting these up nicely.  I applied patches 1 and 2.

I haven't had time to investigate the problem I was having with
"cat $DATA", and I'm going on vacation for a week starting
tomorrow.  So I'll have to look at that when I get back.

As for patch 3, that's an interesting concept.  My initial reaction
is that it seems sort of backwards to put this sort of "binary ->
ASCII" decoding mechanism into the kernel or the prom.

I can see that it might be convenient to be able to stash all
that secret IP in the prom, and it certainly does address the
problem of version skew, but it just seems wrong to get the
kernel in the middle, ferrying data back and forth.

HP has the same problem, of course, with wanting to protect
the meaning of the OEM data, so I had imagined some sort
of binary-only user-level decoder, or perhaps a generic
open-source decoder to which one could add proprietary
plugins.

If you really want the decoding in the prom, what about a
module that allowed you to make arbitrary SAL calls from
user-land?

Bjorn

