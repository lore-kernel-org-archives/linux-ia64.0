From: Steffen Persvold <sp@scali.no>
Date: Thu, 30 Aug 2001 06:39:06 +0000
Subject: [Linux-ia64] Re: Write Combining (Write Coalescing) on memory mapped I/O on IA64.
Message-Id: <marc-linux-ia64-105590698805107@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805106@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805106@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
> >>>>> On Sat, 25 Aug 2001 16:40:24 +0200, Steffen Persvold <sp@scali.no> said:
> 
>   Steffen> Just a repost since I didn't get any feedback. I've also
>   Steffen> copied some auhtors I found in asm/io.h. I appologize for
>   Steffen> any inconvenience, but this issue is quite important to us.
> 
> I didn't see anything fundamentally wrong with what you're trying to
> do, but I haven't looked at the code.  Some debugging may be called
> for.
> 

Do you think it's easier to set up a region which is mapped all the time, so
that ioremap_nocache() uses the already defined region 6 for uncached accesses
and ioremap() uses this new region with "Write Coalescing" enabled ? How should
I proceed to introduce such a region ?

Regards,
-- 
  Steffen Persvold   |  Scali Computer AS   |   Try out the world's best   
 mailto:sp@scali.no  | http://www.scali.com | performing MPI implementation:
Tel: (+47) 2262 8950 |  Olaf Helsets vei 6  |      - ScaMPI 1.12.2 -         
Fax: (+47) 2262 8951 |  N0621 Oslo, NORWAY  | >310MBytes/s and <4uS latency

