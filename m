From: Cary Coutant <cary@cup.hp.com>
Date: Tue, 21 Oct 2003 20:37:00 +0000
Subject: Re: [RFC] Endianness and signals
Message-Id: <marc-linux-ia64-106676921219872@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106669369711349@msgid-missing>
In-Reply-To: <marc-linux-ia64-106669369711349@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I don't think the psABI requires twiddling the PSR.be bit on signal
> delivery (though it probably also does not disallow it).  The thing
> is, if you have an applications that's completely big-endian, you'd
> probably NOT want to clear PSR.be on a signal.  On the other hand, if
> you just have one or two routines which turn on PSR.be, then clearing
> the bit is clearly advantageous (e.g., would avoid sigprocmask()
> calls).  But given that the current kernel behavior has existed for a
> long time, I'm not sure it's a good idea to change the behavior now
> (it's not like you _can't_ have big-endian code at the moment).

The psABI doesn't really admit to the existence of mixed-endian 
processes.

I think the right thing to do is set the PSR.be bit on delivery of a 
signal to match (elf_header.e_flags & EF_IA_64_BE). If the process is 
primarily little-endian with an occasional excursion into big-endian 
mode, one would expect (and reasonably require) the application's 
signal handlers to run in little-endian mode. If you've got a 
big-endian process that switches into little-endian mode only to make 
system calls, one would expect its signal handlers to run in big-endian 
mode.

I'm not sure I buy the argument that you shouldn't change the behavior 
now because it's been that way for a long time. What you have now is 
unpredictable, so the only ways a signal handler could work in an 
application that switches the PSR.be bit on a regular basis are: (1) it 
just gets lucky, and never gets an interrupt while in the wrong state, 
(2) the application blocks signals while in the opposite state, or (3) 
the signal handler forces the PSR.be to what it wants. In any of these 
cases, the proposed behavior will work.

-cary

