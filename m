From: Jack Steiner <steiner@sgi.com>
Date: Wed, 21 Feb 2001 19:48:14 +0000
Subject: Re: Re: [Linux-ia64] Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005183@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Anyway, I have ITPs connected to the IBM hardware and have noticed that
> when the lockup occurs, and we lose video, at least one of the CPUs is
> executing in flush_tlb_no_ptcg() or handle_IPI(), in the 'do' loop where
> TLB
> entries are being purged. What I have observed is that the end address and
> the start address are in completely different regions. Usually, the start
> address
> is in region register 1 (address of 0x2000XXXXXXXXXXXX) and the end address
> is in region register 3 (address of 0x6000XXXXXXXXXXXX). I don't know if
> this
> is the same problem I am seeing on the Lion, but I plan to connect and ITP
> and
> a serial console (although we haven't been able to get one to work yet on
> the
> Lion with BIOS 71) to see if the symptoms are the same.

FWIW, we have seen EXACTLY the same hang running here on our system.
The start/end addresses for the purge cross region boundaries.


We are running a 2.4.0 kernel.


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


