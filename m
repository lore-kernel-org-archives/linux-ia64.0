From: Pete Wyckoff <pw@osc.edu>
Date: Mon, 09 Oct 2000 16:03:58 +0000
Subject: Re: [Linux-ia64] avoiding float underflow software assist
Message-Id: <marc-linux-ia64-105590678205560@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205556@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205556@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dan.Pop@cern.ch said:
> On Mon, 9 Oct 2000, Pete Wyckoff wrote:
> > This little code snippet causes floating-point underflow during the
> > multiplication.
> Try this code and see if it helps.  You don't have to explicitly call
> the function, it will be automatically executed before main().

Excellent.  I can manage to get this linked in with the fortran
application from whence the problem sprung, which is what I really
wanted.

Gcc and glibc seem only to care about st0.  The "minimal" fix,
which relies on glibc and exercises its fe*env functions, is:

    #include <fenv.h>
    #include <asm/fpu.h>

    fenv_t envp;
    fegetenv(&envp);
    envp |= FPSR_S0(FPSF_FTZ);
    fesetenv(&envp);

Helped me to understand what's going on.

Thanks,
		-- Pete

