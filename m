From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 17 Nov 2003 15:48:15 +0000
Subject: Re: Newbie: General Complile Issues
Message-Id: <marc-linux-ia64-106908480024444@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106908237920741@msgid-missing>
In-Reply-To: <marc-linux-ia64-106908237920741@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2003-11-17 at 08:19, Dan Am wrote:
> Hi,
> sorry to to bother the gurus with mere admin view questions. I got hold of a 
> zx6000 with RHAS 2.1, got the book and I am taking her out for a spin, so to 
> speak.  
> Here goes: 
> 
> 1. Which is the "correct" source ? Kernel Org or bkbits ? 

   Either, for 2.4 make sure you have Bjorn's patch or use his bk tree
(linux-ia64-2.4).  For 2.6, you don't need the ia64 patch, but, see next
answer.

> 2. Will the 2.6-test1 that I am using (compiling now with gcc3.1 from hpl) not 
> run ? 

   test9 definitely works, via kernel.org, standard bk or ia64 bk. 
Unless you really need test1, I'd go with the latest.  I don't remember
how well test1 worked.

> 3. There is talk of "Mosberger Patches" : Are those required ?  Where can they
>     be found ? 
> 

   For 2.4, yes, but they're now Bjorn patches.   They are not required
for 2.6.  You can find them all here:
http://www.kernel.org/pub/linux/kernel/ports/ia64/

> Thanks a million for bothering. Of course, if there is a FAQ on those q's, or 
> a better list, I'd be reading that. Grateful for a pointer in that case. 
> 

   You might want to check http://www.gelato.org, there's some useful
information there.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

