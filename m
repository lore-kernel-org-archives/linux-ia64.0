From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 Jun 2002 18:41:49 +0000
Subject: Re: [Linux-ia64] /usr/lib/gcrt1.o on RH 7.2
Message-Id: <marc-linux-ia64-105590701905701@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905700@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905700@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 21 Jun 2002 23:21:35 +0900, "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp> said:

  Hideki>  Recently, I have been using RH 7.2 on ia64.  Then I noticed
  Hideki> that /usr/lib/gcrt1.o is wrong because I could not get
  Hideki> result of gpof correctly.  When some of programs are compild
  Hideki> with -p switch and run them. After that, I wanted to confirm
  Hideki> the infomation by profiler using gprof command, but gprof
  Hideki> could not run correctly, it gives me wrong result or nothing
  Hideki> display or illegal instrcution.

  Hideki>  Does anyone already have any patches or any good idea?

I haven't tried profiling on Red Hat recently, but in general,
gprof-based profiling does work.  I did try on Debian just a few days
ago and it worked great.

	--david

