From: "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp>
Date: Sat, 22 Jun 2002 06:16:15 +0000
Subject: Re: [Linux-ia64] /usr/lib/gcrt1.o on RH 7.2
Message-Id: <marc-linux-ia64-105590701905702@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905700@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905700@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 Dear David,

 Let me know glibc version in your site which you did try.
 
 I mean that profiling on RH 7.1 worked file, but it
 does not work on RH 7.2. 
 I think that this issue is caused by /usr/lib/gcrt1.o
 based on glibc-2.2.4.

 After I found out this issue, I tried to use gcrt1.o
based on glibc-2.2.3 instead of gcrt1.o based on
glibc-2.2.4.
 It works fine. but I am afraid that this way gives a
bad effect to another programs. I mean that I do not
know how /usr/lib/gcrt1.o is used or which program use
/usr/lib/glibc1.o without profiling program made by -p.

End of my email
--
Yours faithfully,
Hideki Yamamoto   (V).v.(V) # Empowered by Innovation
 

At Fri, 21 Jun 2002 11:41:49 -0700,
David Mosberger wrote:
> 
> >>>>> On Fri, 21 Jun 2002 23:21:35 +0900, "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp> said:
> 
>   Hideki>  Recently, I have been using RH 7.2 on ia64.  Then I noticed
>   Hideki> that /usr/lib/gcrt1.o is wrong because I could not get
>   Hideki> result of gpof correctly.  When some of programs are compild
>   Hideki> with -p switch and run them. After that, I wanted to confirm
>   Hideki> the infomation by profiler using gprof command, but gprof
>   Hideki> could not run correctly, it gives me wrong result or nothing
>   Hideki> display or illegal instrcution.
> 
>   Hideki>  Does anyone already have any patches or any good idea?
> 
> I haven't tried profiling on Red Hat recently, but in general,
> gprof-based profiling does work.  I did try on Debian just a few days
> ago and it worked great.
> 
> 	--david
> 

