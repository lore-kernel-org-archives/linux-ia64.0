From: Don Dugger <n0ano@valinux.com>
Date: Thu, 26 Jul 2001 23:32:27 +0000
Subject: Re: [Linux-ia64] gcc 3.0 question: ILP32 mode ?
Message-Id: <marc-linux-ia64-105590693005938@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jose-

My assumption is that if a program is not worth porting to IA64
then you should just leave it as an IA32 program.  If it is worth
porting to IA64 then port it to a full 64-bit implementation.

We've thought about creating a 32-bit IA64 model may times in the
past and everytime we've done that we've reached the conclusion
that it just is not worth the effort and we fall back to the
original assumption.

Also, I predict you need lots more that just `libc' and `libX11'.
Just off the top of my head I know you'll need `ld.so' and `libm'.
I've got 19 `.so's in my `/usr/X11R6/lib' directory so you'll probably
need most of them.  Make a 32-bit mode available and somebody, somewhere
will want every available library in that mode.

Just say no :-) 

On Fri, Jul 27, 2001 at 12:42:25AM +0200, Jose Luu wrote:
> 
> Hans wrote:
> > Supporting another ABI is very expensive.  The tradeoffs for HP/UX are
> > different.
> >
> 
> I am sure I don't realize how expensive it is, but it seems worth
> investigating, for our purposes we need the libc and libX11, little else.
> 
> Some code is just not worth cleaning up because it is too big, and will
> never require 64 bit addressing, but still useful to have in native mode,
> mostly because of the performance gap between ia32 and ILP32 which will
> moreover widen with the McKinley chip. Look at netscape, it has never been
> cleaned up, it was ported on linux alpha using the DEC/Compaq/(Intel now?)
> compiler in taso mode (32 bit pointers).
> 
> DEC/Compaq developped a technology for VMS where one can mix 32 and 64 bit
> libraries, I am wondering if the same ideas can be applied here (see
> references below), nowadays this technology should be with Intel. This would
> avoid the fork in the ABI.
> 
> References:
> http://www.research.compaq.com/wrl/DECarchives/DTJ/DTJM06/DTJM06HM.HTM and
> http://www.research.compaq.com/wrl/DECarchives/DTJ/DTJM07/DTJM07HM.HTM
> 
> Jose
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

