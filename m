From: Pete Wyckoff <pw@osc.edu>
Date: Mon, 13 Nov 2000 16:57:17 +0000
Subject: Re: [Linux-ia64] Performance Monitor Internals:
Message-Id: <marc-linux-ia64-105590678205689@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205661@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205661@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

davidm@hpl.hp.com said:
> static __inline__ unsigned long
> ia64_get_itc (void)
> {
> 	unsigned long result;
> 
> 	__asm__ __volatile__("mov %0=ar.itc" : "=r"(result) :: "memory");
> 	while (__builtin_expect ((int) result = -1, 0))
> 		__asm__ __volatile__("mov %0=ar.itc" : "=r"(result) :: "memory");
> 	return result;
> }

Why is it no good to return result when it satisfies:

    (result & 0xffffffff) = 0xffffffff

?  Curiosity.

		-- Pete

