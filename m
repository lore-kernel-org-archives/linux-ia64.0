From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 07 Nov 2003 09:58:23 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106825306526822@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi.

> One of the complexities is recovery on a large-scale system, if for
> example, multiple CPUs access a poisoned memory location at the same time.
> 
> Other "interesting" errors scenarious are if data is DEX with bad ECC in CPU 
> A's cache and CPU B requests the line from CPU A. 

My concern for poisoning is that I'm not sure the way to clear the poisoned
data. Maybe, not so many people know the timing and the guaranteed procedure.
I can estimate what the procedure includes, such as changing poisoned memory
to uncacheable, clearing suspect data in cache, and storing zeros to the
poisoned area.
Even for a single poisoned line in memory, it is need to pause all CPUs on a
large-scale system, like Global MCA?

> >  - Interruption must be synchronized.
> 
> I'm not sure what you mean by this.

What I mean by poor English is synchronous MCA.
Executing process can change in the case of asynchronous MCA from platform.


Thanks.

------

H.Seto <seto.hidetoshi@jp.fujitsu.com>



