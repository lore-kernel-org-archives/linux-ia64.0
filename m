From: k Macy <kip_macy@yahoo.com>
Date: Wed, 05 Sep 2001 18:14:38 +0000
Subject: Re: [Linux-ia64] can't compile on x86 - building cross-compiler for ia64 getting SIGSEGV
Message-Id: <marc-linux-ia64-105590698805125@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805115@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805115@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It looks like in both cases it was my fault,
when building the compiler I set the --host=ia64...
when it should have been --target=ia64...
When building 2.4.9 I hadn't downloaded and applied
the latest patches to the tree. The default IA64 in
the linux tree is pretty broken.

In both cases the compiler should have failed a lot 
more gracefully, but it sounds like 32bit->64bit
cross-compilation is non-trivial.

Thanks.

           -Kip

--- Jim Wilson <wilson@cygnus.com> wrote:
> >Current gcc code will not cross compile from ix86
> to ia64, it gets
> >problems with conditional return of 64 bit values
> in some functions.
> 
> A bug report would be very useful, yes.  You didn't
> even mention what
> program is being miscompiled.  If you have already
> reported the bug, please
> point me at the report.
> 
> Jim


__________________________________________________
Do You Yahoo!?
Get email alerts & NEW webcam video instant messaging with Yahoo! Messenger
http://im.yahoo.com

