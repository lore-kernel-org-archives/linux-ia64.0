From: Cary Coutant <cary@cup.hp.com>
Date: Sat, 24 Mar 2001 00:58:59 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005348@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I don't know who Cary is

For those who don't know me, I'm responsible for the HP-UX runtime 
architecture on both PA-RISC and IA-64. I've worked with Intel on IA-64 
from the beginning, contributed to the hardware architecture, co-led the 
development of the runtime architecture, and wrote a large part of the 
Software Conventions and Runtime Architecture document, including all of 
the unwind chapter. (Sometimes I don't like to admit that when it becomes 
evident that I neglected a corner case such as the one we're now 
discussing!)

While I don't participate in the Linux implementation effort (though I'd 
like to), I keep an eye on this mailing list to catch and correct issues 
like this one.


>When unwinding, we are doing a table lookup.  The address space is split into
>a bunch of separate unwind regions, each one stopping where the next one
>starts.  This leaves us vulnerable to boundary crossing problems.  If a call
>occurs in the last bundle of an unwind region, then the return address points
>to the next unwind region.

Except for calls to noreturn procedures (which I failed to anticipate in 
the design and specification of the unwind architecture), the return 
point must always be in the same unwind region as the call, because 
nothing can happen to change the unwind state between the call and the 
return point.


>Similarly, when doing C++ exception handling, we are doing a table lookup.
>The address space in split into a bunch of separate exception regions, and
>there is a boundary-crossing problem if a call is the last instruction of an
>exception region.

To me, the EH model is better thought of not as a set of regions, but as 
a set of discrete points in the code where an exception can be raised. 
Each of these points, most of which are return points following calls, 
can be described in the EH tables without any ambiguity about what region 
the IP address belongs to.


-cary

