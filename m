From: Einar Saltnes <eisa@scali.no>
Date: Tue, 17 Oct 2000 14:49:35 +0000
Subject: Re: [Linux-ia64] clock stops on test9
Message-Id: <marc-linux-ia64-105590678205574@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205567@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205567@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Ahna, Christopher J" wrote:
> 
> Einar,
> 
> Are you building your test9 kernel with A1-specific fixes enabled?
> A1-specific fixes deal with interrupt handling and have historically caused
> problems like the one you're seeing on non-A1 stepping Itaniums.  Thanks,
> 
> Chris
> 
Hi,

on my Dual B1-stepping Itanium I have now only enabled the
BSTEP_SPECIFIC setting. But the clock will still stop after some time.

On my UP A2-stepping Itanium, however, I have enabled both the ASTEP_-
and the A1_SPECIFIC setting. On this machine it doesn't seem to be a
problem with the clock. Uptime today is four days.

As David M. pointed out, I will compile a new kernel enabling only the
ASTEP_SPECIFIC setting for the A2-stepping BigSur as this will be the
correct configuration for the actual processor.

I will also make some tests on a Dual A3-stepping BigSur with BIOS 60
which just came in my door...

Thanks!

Einar
-- 
| Einar Saltnes          |         Scali AS         |
| mailto:eisa@scali.no   |   http://www.scali.com   |
| Phone:+47 22 62 89 50  |  Scalable Linux Systems  |
| Fax  :+47 22 62 89 51  |      and Technology      |

