From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 13 Nov 2000 22:37:55 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test10 and upper?
Message-Id: <marc-linux-ia64-105590678205706@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I tried building glibc 2.2 (just released today on freshmeat.com) but
>when building with the original compiler (Red Hat August release) I had

I assume you mean the Red Hat August Linux OS release.  Red Hat isn't just a
linux company anymore.  There were also compiler releases in August.  The
August OS release uses the February compiler, which is obsolete, and probably
won't compile any recent linux kernels.  Use the new compiler, which reports
itself as "2.96-ia64-000717 snap 001024".

>  The latest snapshot seems to define these, but crash
>a lot.  Is there something in the middle you'd recommend?

Unreproducible crashes are due to hardware, firmware, and/or kernel problems.
This is not a compiler problem.  If you have an A-step or B0-step machine,
then you need to use the -ma-step option to workaround around hardware
problems.  If you have a B2-step machine, then you need a firmware version
that Intel hasn't released yet, but will hopefully release soon.  There are
also other possible, though less common, explanations for this problem.

If you are seeing reproducible compiler problems, then I'd like to hear about
them.

Jim

