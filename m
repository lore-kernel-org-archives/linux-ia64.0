From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 13 Jul 2011 21:47:51 +0000
Subject: RE: ia64: replace old cpumask functions with new one
Message-Id: <987664A83D2D224EAE907B061CE93D5301E9C9F80E@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4E031B97.2010609@jp.fujitsu.com>
 <CA+8MBbLg4jBmaYkVW13WReNm8nyP1p0k3CPN=pQmvwPfRKyeQA@mail.gmail.com>
 <4E1C055C.1030103@jp.fujitsu.com>
In-Reply-To: <4E1C055C.1030103@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> But ummm.. I can't understand the author expect which effect by this volatile.
> If I am correct, its volatile has no effect. we can simply remove it.

It may be a legacy from when cpumask was a simple integer type. The
boot cpu wakes up each "AP" cpu in turn - and spins looking at
cpu_callin_mask waiting to see if the cpu has really woken up,
since the AP cpu will set its own bit in this mask when it begins
execution.

Making the original integer mask a volatile was a way to make
sure that the compiler did not optimize away the re-read of
this variable in the loop.

When NR_CPUS is small enough - we still use a simple
integer for cpumask type - don't we? So if you remove
the volatile, look very carefully at this loop:

        for (timeout = 0; timeout < 100000; timeout++) {
                if (cpu_isset(cpu, cpu_callin_map))
                        break;  /* It has booted */
                udelay(100);
        }

to make sure that the cpu_isset() check really does look
at cpu_callin_map every time (and not at some cached in a
register copy of it). Booting would become painfully slow
if we get stuck for 10 seconds per cpu just here.

-Tony


