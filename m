From: Takayoshi Kouchi <kouchi@hpc.bs1.fc.nec.co.jp>
Date: Wed, 18 Oct 2000 02:05:26 +0000
Subject: Re: [Linux-ia64] clock stops on test9
Message-Id: <marc-linux-ia64-105590678205588@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205567@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205567@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

From: Einar Saltnes <eisa@scali.no>
Subject: Re: [Linux-ia64] clock stops on test9

> >   Einar> However, there are some problems with the system clock. The
> >   Einar> BIOS clock seems to run OK, but in linux the clock seems to
> >   Einar> stop after some random time. When using "date", time stands
> >   Einar> still after some random time! This gives me some trouble
> >   Einar> using other utilities e.g. ping and even shutdown.  This
> >   Einar> shows only on the dual B1-stepping box and not the UP
> >   Einar> A2-stepping box. It can run OK for a few minutes or for some
> >   Einar> hours.  Anyone got a clue?
> > 
> > Doesn't sound familiar.  It's very unlikely to be a hardware problem
> > because the kernel's timer tick runs off the CPU cycle counter.  Where
> > did you get the test9 kernel from and what version of the toolchain
> > was used to compile it?

We have seen the same problem as yours.  We have upgraded our BigSur
with an upgrade kit from Intel.  It had originally only one processor,
but we replaced it with two B0 processors.  
While running 2.4.0-test9 kernel, we noticed that timer interrupt of CPU0
would stop at some time after boot.
Below is a /proc/stat of that problem.

luna:~% cat /proc/stat
cpu  932275 0 52697 18446744073709470016
cpu0 372675 0 23555 55456
cpu1 559600 0 29142 18446744073709414560
page 3907 771
swap 1 0
intr 1158056 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1363 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 9299 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 6 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 642 1 2 0 1 0 0 1 1 0 0 0 0 0 0 0 8 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1067645 0 0 0 0 0 0 0 0 0 0 0 0 0 0 79080 0
disk_io: (8,0):(1329,601,31038,728,6168) 
ctxt 24320
btime 971772286
processes 541

Once timer interrupt stops, jiffies will not be incremented.
That causes idle time to be negative.

> OK, I have compiled a new kernel with only BSTEP_ enabled. Same story.
> Using "date" I observe that time stops approx 20 minutes after boot of
> the new kernel.
> However, "cat /proc/efirtc" seems to show correct numbers. BTW, is this
> the output of the HWclock? Is this the same source as "date" gets its
> numbers from?

"date" output is calculated from times of timer interrupt.
If CPU0's timer interrupt stops, then counting jiffies (timer interrupt
counter) will also stop.  Then "date" indicates the same time.

We'are investigating why the timer interrupt stops.

---
Takayoshi Kouchi, NEC solutions

