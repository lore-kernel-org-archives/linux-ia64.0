From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 28 Jan 2004 15:42:54 +0000
Subject: Re: [RFC/PATCH, 3/4] readX_check() performance evaluation
Message-Id: <16407.55422.229863.840323@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a401c3e541$c1d347f0$2987110a@lsd.css.fujitsu.com>
In-Reply-To: <00a401c3e541$c1d347f0$2987110a@lsd.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hironobu Ishii <ishii.hironobu@jp.fujitsu.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>

>>>>> On Wed, 28 Jan 2004 10:54:42 +0900, Hironobu Ishii <ishii.hironobu@jp.fujitsu.com> said:

  Hironobu> This is a patch for rawread 1.0.3.
  Hironobu> Original rawread 1.0.3 depends on i386.

  Hironobu> --- rawread.c.old 2004-01-22 19:33:43.000000000 +0900
  Hironobu> +++ rawread.c 2004-01-27 23:26:24.406717936 +0900
  Hironobu> @@ -94,8 +94,14 @@

  Hironobu> __inline__ unsigned long long int rdtsc()
  Hironobu> {
  Hironobu> -  unsigned long long int x;
  Hironobu> -  __asm__ volatile (".byte 0x0f, 0x31" : "=A" (x));
  Hironobu> + unsigned long long int x;
  Hironobu> +#if __i386__
  Hironobu> + __asm__ volatile (".byte 0x0f, 0x31" : "=A" (x));
  Hironobu> +#elif __ia64__
  Hironobu> + __asm__ volatile ("mov r8 = ar44");
  Hironobu> +#else
  Hironobu> + #error "Please write your own rdtsc()"
  Hironobu> +#endif
  Hironobu> return x;
  Hironobu> }

Inline assembly doesn't work with the Intel compiler on ia64.  I
suggest to use ia64_get_itc() defined in <asm/delay.h> instead.

	--david
