From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Mon, 25 Jun 2001 11:37:43 +0000
Subject: Re: [Linux-ia64] IO/TLB bounce buffer space
Message-Id: <marc-linux-ia64-105590693005754@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005716@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005716@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dear Rich, all,

> In my experience, the question of the peak demand a system may
> experience must be governed by
> 1. what you, the supplier, spec as the peak demand it supports,
> 2. what the customer understands is the max load the system
>     can be utilized to perform, and have paid to obtain.
> 3. and any shortfall in actual delivered performance from your spec
>     you can be sure the customer will demand you the supplier pay
>     to make up the difference!
>
> This leaves no room for statistical analysis!   The customer will not
> view that using all the resources at once is unlikely and not expected.
> If you spec 4 controllers of 32 devices each of 253 buffers needed for
> their peak operation, then the system better deliver this.
> Or you should change your spec and reduce the numbers.

I completely agree with you. I just didn't want to sound too harsh in my
analysis of the problem (the harsh version is: This controller/driver
combination is not suitable for production systems on IA/64).

Justing Gibbs is implementing 39bit addressing into the aix7xxx
driver right now. Once finished, this will solve the problem.

Regards,
Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




