From: Steffen Persvold <sp@scali.no>
Date: Fri, 14 Sep 2001 21:57:03 +0000
Subject: [Linux-ia64] Status on ioremap patch
Message-Id: <marc-linux-ia64-105590698805185@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Steffen Persvold wrote:
> 
> David Mosberger wrote:
> >
> > >>>>> On Mon, 10 Sep 2001 17:26:47 +0200, Steffen Persvold <sp@scali.no> said:
> >
> >   Steffen> This is what my original post (which included a patch)
> >   Steffen> tried to do, but I didn't get it too work. I know you gave
> >   Steffen> me feedback on this David, saying that it just may need
> >   Steffen> some debugging. Does anyone on the list have the time to
> >   Steffen> just look through the patch and try to analyze what's going
> >   Steffen> wrong (or maybe just give me some hints on what to look
> >   Steffen> for) ?
> >
> > I don't, not in the near future at least.
> >
> > There is nothing magical about debugging on ia64.  Just use the normal
> > techniques: try to narrow down what's triggering the problem, e.g.,
> > via binary search, printk, etc.  A kdb patch is also available.
> >
> 
> Yep, I know. But I managed to solve it without the use of kdb. It was just a
> question of using the right __pgprot flags. I've attached a new patch, it's made
> against 2.4.4 but it also applies cleanly to a vanilla 2.4.9 tree. I guess this
> means that we don't have to use the uncached region 6 anymore; ioremap() could
> be modified to use __ia64_ioremap() with the _PAGE_MA_WC attribute and
> ioremap_nocache() to with the _PAGE_MA_UC attribute. Any comments ?
> 
> I sure hope that this is patch that you would consider going into the main ia64
> tree.
> 

So, how about that patch guys ? Any chance you'll put it into the mainstream
IA64 kernel ???

Regards,
-- 
  Steffen Persvold   |  Scali Computer AS   |   Try out the world's best   
 mailto:sp@scali.no  | http://www.scali.com | performing MPI implementation:
Tel: (+47) 2262 8950 |  Olaf Helsets vei 6  |      - ScaMPI 1.12.2 -         
Fax: (+47) 2262 8951 |  N0621 Oslo, NORWAY  | >300MBytes/s and <4uS latency

