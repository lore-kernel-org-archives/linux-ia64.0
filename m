From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 15 Jan 2003 08:47:14 +0000
Subject: Re: [Linux-ia64] cpu_halt() question
Message-Id: <marc-linux-ia64-105590709805679@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805669@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805669@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Alex Williamson schrieb:

>    I've played around with calling ia64_pal_halt_light() in cpu_idle
> to see if I could impact the power consumption.  Using very crude
> measurements, the temperature at the back of an i2000 dropped ~10
> degrees F adding something simple like:
>
> if (pm_idle)
>     (*pm_idle)();
> else
>     ia64_pal_halt_light();
>
> Unfortunately, on McKinley, the PAL_HALT_LIGHT state claims the same
> power consumption as the full run state.  I've verified that I get
> almost no change in processor temperature by adding this call.  BTW,
> this is PAL_A 0.7.31, PAL_B 0.7.36.
>
>         Alex

Yes, shouldn't we enable the kernel now instead of waiting for future CPUs or
PAL releases? It would be nice to have a "cool" 2.4.x kernel with your simple
modification.

Christian


