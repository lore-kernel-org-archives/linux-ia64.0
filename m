From: Erich Focht <efocht@hpce.nec.com>
Date: Fri, 19 Sep 2003 16:56:21 +0000
Subject: Re: [PATCH] fix build_zonelists for CONFIG_ACPI_NUMA
Message-Id: <marc-linux-ia64-106399086014009@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106383460616067@msgid-missing>
In-Reply-To: <marc-linux-ia64-106383460616067@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 18 September 2003 21:59, Jesse Barnes wrote:
> On second thought, here's the output from a test machine here.  I think
> it's working correctly.
>
> ...
> ACPI 2.0 SLIT locality table:
> 010 020 022 042
> 020 010 042 022
> 022 042 010 020
> 042 022 020 010

That unsymmetric??? Interesting... Of course this saves you the
headache of explicitely round-robin.

> Which I think you were worried about?

I'm still worried about the "normal" kind of machines with more
symmetric node-distances. TX-7 for example has

10 15 15 15 20 20 20 20
15 10 15 15 20 20 20 20
15 15 10 15 20 20 20 20
15 15 15 10 20 20 20 20
20 20 20 20 10 15 15 15
20 20 20 20 15 10 15 15
20 20 20 20 15 15 10 15
20 20 20 20 15 15 15 10

I'm fine with sorting if we get some sort of round-robin at least over
the first off-diagonal node level. But the code I've sent you was the
best idea I had (in the limited time I could spend for this...).

Regards,
Erich


