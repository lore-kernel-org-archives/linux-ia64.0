From: "Boehm, Hans" <hans_boehm@hp.com>
Date: Tue, 30 Sep 2003 23:35:56 +0000
Subject: RE: ia64_cmpxchg on United Linux 1.0
Message-Id: <marc-linux-ia64-106496505103304@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106496180632562@msgid-missing>
In-Reply-To: <marc-linux-ia64-106496180632562@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You might want to look at the atomic operations package that's included
here: http://www.hpl.hp.com/research/linux/qprof/download.php4 .

This isn't exactly a mature package, but I'm trying to get it there.
IA64 is relatively well-supported.  And AFAIK, it's the only such package
that handles memory barriers explicitly and correctly (at least by
my definition of "correctly" :-) ).

Suggestions/bug reports/patches are welcome.

Hans

> -----Original Message-----
> From: Umut Aymakoglu [mailto:umuta@us.ibm.com]
> Sent: Tuesday, September 30, 2003 3:39 PM
> To: linux-ia64@vger.kernel.org
> Subject: ia64_cmpxchg on United Linux 1.0
> 
> 
> 
> 
> 
> 
> Hi -
>    The macro used for test_and_set (ia64_cmpxchg) asm/atomic.h or
> asm/spinlock.h on United Linux 1.0 is under #ifdef _KERNEL_  
> and therefore
> can not be used in  user applications.  In RHAT 2.1 it was 
> not under #ifdef
> _KERNEL_ . Is there another macro for test_and_set  that user 
> applications
> can use?
> 
> thanks,
> Umut
> 
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
