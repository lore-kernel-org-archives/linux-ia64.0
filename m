From: Scott Hankin <shankin@rational.com>
Date: Mon, 13 Nov 2000 22:09:35 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels
Message-Id: <marc-linux-ia64-105590678205705@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I am not a kernel expert.  I do not build my own kernels.  I can not tell you
>which compiler versions are best for compiling which kernel versions.
>
>However, in general, I recommend the most recent toolchain snapshot available
>at  ftp://ftp.cygnus.com/pub/ia64-linux.  These toolchains assume glibc 2.2.
>Unfortunately, sigh, there aren't any glibc 2.2 based OS releases yet, but
>this shouldn't matter if you are just building kernels.

I tried building glibc 2.2 (just released today on freshmeat.com) but
when building with the original compiler (Red Hat August release) I had
compile errors with sysdeps/ia64/fpu/s_isnanl.S - nat, qnan and snan
weren't defined.  The latest snapshot seems to define these, but crash
a lot.  Is there something in the middle you'd recommend?

- Scott

-----------------------------
Scott Hankin                  In the beginning, there was nothing, then
Rational Software             God said, "Let there be light."  And there
20 Maguire Road               was light.  There was still nothing, but
Lexington, MA 02421           you could see it a lot better.

