From: Steffen Persvold <sp@scali.no>
Date: Wed, 09 Jan 2002 20:01:13 +0000
Subject: Re: [Linux-ia64] Re: Status on ioremap patch
Message-Id: <marc-linux-ia64-105590698805782@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805186@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805186@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Steffen Persvold wrote:
> 
> David Mosberger wrote:
> >
> > Steffen,
> >
> > I looked at your patch and have a comment and a suggestion.  First, I
> > do not think it's safe to define ioremap() as a way to install
> > write-cached mappings.  There are plenty of drivers left that use
> > ioremap() instead of ioremap_nocache() and we can't change the
> > semantics of ioremap() underneath them.
> >
> > Second, it seems to me it would be cleaner to extend
> > remap_page_range() to allow remapping into the kernel mapped segment
> > (region 5 in the case of ia64 linux).  This should work as is, except
> > that in the kernel case, you need to use pgd_offset_k().  I think you
> > could hack mm/memory.c to check whether "from" is in the range from
> > VMALLOC_START to VMALLOC_END and, if so, use pgd_offset_k() instead of
> > pgd_offset().  Can you try this and let me know if it works for your
> > needs?
> >
> 
> I've had some time to look at it, and I decided to do what you said. I also changed ioremap on all
> platforms that implements it so that they use remap_page_range()). I've tested the patch on IA64 and
> i386.
> 
> I've attached the patch (I didn't post it on the lkml even though it affects more that the IA64
> platform), it's against a vanilla 2.4.17 tree.
> 
> Please take a look and tell me what you think.
> 

So, what about this patch (posted earlier) David ? Have you seen the comments from Keith ? 

Regards,
-- 
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best   
 mailto:sp@scali.no  |  http://www.scali.com  | performing MPI implementation:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.12.2 -         
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >300MBytes/s and <4uS latency

