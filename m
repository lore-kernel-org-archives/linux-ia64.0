From: Andrew Haley <aph@cambridge.redhat.com>
Date: Fri, 21 Sep 2001 08:41:05 +0000
Subject: Re: [Linux-ia64] getcontext() correctly implemented ?
Message-Id: <marc-linux-ia64-105590698805235@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805230@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805230@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

stefan writes:
 > 
 > The garbage collector of GNU Guile does not need the machine
 > context in a signal handler. It just looks for heap references
 > within the programs stack. The top of the stack is saved when
 > starting the program, the bottom is gained from the current stack
 > position when garbage collecting. More references might be within
 > the machines registers. That is why it uses setjmp() in order to
 > get these into a defined buffer. On a ia64 Linux setjump() is not
 > said to save *all* registers. That is why I thought the
 > getcontext() function could help here. Is that true ? I already
 > tried it with glibc 2.2.3 without success. Still missed some
 > references...

I can't help thinking you'd be best looking at Hans Boehm's garbage
collector and the way it accesses registers on IA-64.  boehm-gc is in
a subdir of the gcc soures.

Andrew.


