From: Steffen Persvold <sp@scali.no>
Date: Mon, 10 Sep 2001 15:26:47 +0000
Subject: Re: [Linux-ia64] Re: Write Combining (Write Coalescing) on memory mapped
Message-Id: <marc-linux-ia64-105590698805153@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805106@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805106@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
> >>>>> On Mon, 10 Sep 2001 16:16:31 +0200, Steffen Persvold <sp@scali.no> said:
> 
>   Steffen> Steffen Persvold wrote:
> 
>   >> Do you think it's easier to set up a region which is mapped all
>   >> the time, so that ioremap_nocache() uses the already defined
>   >> region 6 for uncached accesses and ioremap() uses this new region
>   >> with "Write Coalescing" enabled ? How should I proceed to
>   >> introduce such a region ?
> 
>   Steffen> I haven't received any response. Does that mean that you
>   Steffen> guys don't even care about this issue ??
> 
> I thought I had answered this already: I don't think it's worthwhile
> to use up another region for write combining mappings.  There are no
> free regions at the moment at any rate.  It's quite possible that
> we'll get rid of the uncached region at some point in the future as
> well.
> 

OK, so what you're saying is that the final solution is to use a i386 kind of
approach to the problem ? This is what my original post (which included a patch)
tried to do, but I didn't get it too work. I know you gave me feedback on this
David, saying that it just may need some debugging. Does anyone on the list have
the time to just look through the patch and try to analyze what's going wrong
(or maybe just give me some hints on what to look for) ? The Oops I get is :

"Unable to handle kernel paging request at virtual address 0xa00000000015c000"

Thanks,
-- 
  Steffen Persvold   |  Scali Computer AS   |   Try out the world's best   
 mailto:sp@scali.no  | http://www.scali.com | performing MPI implementation:
Tel: (+47) 2262 8950 |  Olaf Helsets vei 6  |      - ScaMPI 1.12.2 -         
Fax: (+47) 2262 8951 |  N0621 Oslo, NORWAY  | >300MBytes/s and <4uS latency

