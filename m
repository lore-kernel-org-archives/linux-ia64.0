From: Erich Focht <efocht@ess.nec.de>
Date: Wed, 03 Apr 2002 21:29:58 +0000
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)
Message-Id: <marc-linux-ia64-105590701905370@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905358@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905358@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Has anyone seen random SIGILL failures in the strncpy
> function in glibc-2.2.4-19.3?
>
> The failure is caused by a NAT consumption fault in the 
> code sequence shown below. 

I've seen NaT consumption faults with an ISV application in a loop
involving speculative loads, too. It was very hard to trace back (occured
at different simulation times in a huge case) and disappeared after we
rewrote the loop and used the latest Intel Fortran compiler. It occured
with both B3 and C0 CPUs under 2.4.7 and 2.4.17. I don't have a testcase
for this, sorry.

Regards,
Erich



