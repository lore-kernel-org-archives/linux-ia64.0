From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Fri, 07 Nov 2003 10:52:23 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106825306526825@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> My concern for poisoning is that I'm not sure the way to clear the poisoned
> data. Maybe, not so many people know the timing and the guaranteed procedure.
> I can estimate what the procedure includes, such as changing poisoned memory
> to uncacheable, clearing suspect data in cache, and storing zeros to the
> poisoned area.
> Even for a single poisoned line in memory, it is need to pause all CPUs on a
> large-scale system, like Global MCA?

I think before the poisoned location can be cleared, all objects having 
potential references must have been terminated (or suspended ?? but there
are a lot of problems with this).

Once the reference count of the corresponding page is 0, you should be able 
to lock the page and clear out the memory. However, you might have a hard error
in which case it probably would not be good to put the page back into
production. So either adding a flag indicating that the page is not longer
usable or attaching the page to some reaper thread might work.

( On our IRIX implementation I also had added a flag which would note that the 
  page had an increased number of SBEs, so it also would not get re-allocated.
  It's an interesting disussion if a failure can de-generate and a SBE can
  turn into a UCE, but we might get everyone bored with that :-))

> What I mean by poor English is synchronous MCA.
> Executing process can change in the case of asynchronous MCA from platform.

It's my french :)

Are you meaning 

	synchronous MCA is caused within an execution context, for example
    a process is doing a load and hits an exception

whereas a asynchronous MCA could happen when a line is written back
to main memory and this could happen outside of the process's context ?

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

