From: Dan Pop <Dan.Pop@cern.ch>
Date: Mon, 09 Oct 2000 15:37:35 +0000
Subject: Re: [Linux-ia64] avoiding float underflow software assist
Message-Id: <marc-linux-ia64-105590678205558@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205556@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205556@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, 9 Oct 2000, Pete Wyckoff wrote:

> This little code snippet causes floating-point underflow during the
> multiplication.
> 
>         float f, g;
> 	f = 1.3e-23;
> 	g = f * f;
> 
> The kernel handler catches the fault and fixes it up, but that's quite
> slow.
> 
> Is there a way to have the hardware automatically ignore this condition
> and force the result to zero on its own?
> 
> I've tried playing with fesetround() and fesetenv() to see if I could
> manage it, to no avail.

Try this code and see if it helps.  You don't have to explicitly call
the function, it will be automatically executed before main().

    #include <stdio.h>
    #include <asm/fpu.h>

    #define MYFPSF_DEFAULT (FPSF_PC (0x3) | FPSF_RC (FPRC_NEAREST) | FPSF_FTZ)

    #define MYFPSR_DEFAULT   (FPSR_TRAP_VD | FPSR_TRAP_DD | FPSR_TRAP_ZD    \
			     | FPSR_TRAP_OD | FPSR_TRAP_UD | FPSR_TRAP_ID   \
			     | FPSR_S0 (MYFPSF_DEFAULT)                     \
			     | FPSR_S1 (FPSF_DEFAULT | FPSF_TD | FPSF_WRE)  \
			     | FPSR_S2 (MYFPSF_DEFAULT | FPSF_TD)           \
			     | FPSR_S3 (MYFPSF_DEFAULT | FPSF_TD))

    void __attribute__((constructor)) ftz(void)
    {
	register unsigned long st = MYFPSR_DEFAULT;

	__asm__ __volatile__ (";; mov.m ar.fpsr=%0;;" :: "r"(st));
	fprintf(stderr, "Flush to zero enabled for S0, S2 and S3.\n");
    }

Dan


