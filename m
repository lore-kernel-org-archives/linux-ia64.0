From: Keith Owens <kaos@sgi.com>
Date: Thu, 08 Feb 2007 23:59:00 +0000
Subject: Re: [RFC Patch]Use ar.kr2 for smp_processor_id
Message-Id: <20719.1170979140@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1170905324.3230.7.camel@linux-znh>
In-Reply-To: <1170905324.3230.7.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou Nan hai (on 08 Feb 2007 15:14:54 +0800) wrote:
>  I think using a static value to cache getcpu will heavily bounced on
>that cache line contain the static value if multi cpus calls getcpu very
>frequently. 

AFAICT, Tony's suggestion[*] is all in user space, e.g. glibc.  Each
application will get its own thread local copy of the static variable,
there is no globally shared static value so no cache line bouncing.

>  then implement current_thread_info()->cpu in fsys call should be
>better?

Maybe.  Implement it, time it and see which is faster.

[*] http://marc.theaimsgroup.com/?l=linux-ia64&m7087180232044&w=2

BTW Tony, in that code there is no need to initialise cpu to ~0 nor to
test for that value.  On the first call it is guaranteed that ar.k3 !save_ar_k3.

