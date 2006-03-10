From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 10 Mar 2006 09:47:21 +0000
Subject: Re: Fix race in the accessed/dirty bit handlers
Message-Id: <44114B29.7080805@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> CPU A        CPU B       | CPU A       CPU B     | cpu A    cpu B
> -----        -----       | -----       -----     | -----    -----
>              change pte  |                       |
>                          |                       |
> read pte                 |read pte               |read pte
> insert TLB               |           change pte  |insert
> re-read                  |insert                 |re-read
>                          |re-read                |          change pte
>                          |ptc.l

These scenarii assume that the sequence:

	insert TLB
	;;
	re-read

is executed in the same order for everyone as it is coded.

I think a ";;" not sufficient to make sure that the external
visibility of the "itc" to generated purges is established
first for everyone, before the "re-read" becomes visible.

> The manual states that serialization is only necessary before a data 
> access uses the mapping.

It also states on page 3:127:

"The visibility of the itc instruction to generated purges (ptc.g, ptc.ga) 
must occur before subsequent memory operations. From a software 
perspective, this is similar to acquire semantics. Serialization is still 
required to observe the side-effects of the translation being present."

> We do not use the mapping in the function we are 
> discussing

Agreed.

> and I would think that the rfi is certainly serialization 
> enough.

... for the future user mode accesses.

I consider an "itc" as completed when:
1. The new (local) translation is available for any new load / store request
2. There is no chance any more to miss an external purge request

I think we can agree on the 1st point.

As far as the 2nd one is concerned:
In order not to break our synchronization algorithm,
we need here to make sure that the external visibility of the "itc" to
generated purges is established first for everyone, before the "re-read"
becomes visible.

The only instruction I know of to synchronize with the "itc" mechanism is
the "srlz" instruction.

Thanks,

Zoltan


