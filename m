From: Randolph Chung <randolph@tausq.org>
Date: Sun, 23 Jun 2002 06:11:47 +0000
Subject: Re: [Linux-ia64] /usr/lib/gcrt1.o on RH 7.2
Message-Id: <marc-linux-ia64-105590701905712@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905700@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905700@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Hideki> the infomation by profiler using gprof command, but gprof
>   Hideki> could not run correctly, it gives me wrong result or nothing
>   Hideki> display or illegal instrcution.
> 
>   Hideki>  Does anyone already have any patches or any good idea?
> 
> I haven't tried profiling on Red Hat recently, but in general,
> gprof-based profiling does work.  I did try on Debian just a few days
> ago and it worked great.

At least on Debian, if the application is linked against pthread then
compiling with profiling does not work. The resulting binary will die
with a SIGILL on startup. You don't need to actually call any pthread
functions, just linking pthread is enough.

randolph
--  
Randolph Chung
Debian GNU/Linux Developer, hppa/ia64 ports
http://www.tausq.org/

