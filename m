From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 14 Jun 2001 20:06:12 +0000
Subject: Re: [Linux-ia64] setjmp/longjmp redux
Message-Id: <marc-linux-ia64-105590693005734@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005732@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005732@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Jun 2001 15:15:09 -0400, chas williams <chas@cmf.nrl.navy.mil> said:

  Chas> hi, new to the list but i did a little reading of the archives
  Chas> and it seems that setjmp/longjmp cant do what i need -- switch
  Chas> the stack.

  Chas> why do i want to do this?  i am working on porting openafs
  Chas> which provides its own thread library (called lwp) that is
  Chas> implemented with setjmp/longjmp.  what needs to be done in
  Chas> order to make this work?  based on my reading it seems that
  Chas> ar.rnat (???) need to be saved between the context switches?
  Chas> i dont know much about the ia64 architecture so if someone
  Chas> could give me some pointers i would be grateful.

For synchronous context switches ("co-routines"), use
makecontext()/setcontext() et al.  They have been added to glibc
recently.  If you're not familiar with these routines, there is an
example in the glibc source tree in stdlib/tst-setcontext.c.
Additional usage notes can be found in in answer 4.10 of the glibc
FAQ.

	--david

