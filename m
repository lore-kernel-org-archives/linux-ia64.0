From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Tue, 24 Feb 2004 02:14:17 +0000
Subject: Re: 2.6.3 oops ia64 Itanium1 with Silicon Image IDE
Message-Id: <20040224021417.GB18070@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220005623.GI11475@cse.unsw.EDU.AU>
In-Reply-To: <20040220005623.GI11475@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David

PCI_DMA_BUS_IS_PHYS to 0

boots OK

PCI_DMA_BUS_IS_PHYS Oxffffffff
&
PCI_DMA_BUS_IS_PHYS OxffffffffUL

fail

Before continuing with this there are more serious problems with
the slab layer, see my post (BUG) slab error....

Thanks
Darren




On Thu, 19 Feb 2004, David Mosberger wrote:

> >>>>> On Fri, 20 Feb 2004 13:55:08 +1100, Darren Williams <dsw@gelato.unsw.edu.au> said:
> 
>   Darren> Hi David I will try the first option of setting
> 
>   Darren> PCI_DMA_BUS_IS_PHYS to 0
> 
>   Darren> and report back.
> 
> OK.  It would be interesting to know whether the ISA_DMA_THRESHOLD
> fix also works, since that would be more likel to qualify as a permanent
> fix.
> 
>   Darren> I know we must be the only people in the world that uses
>   Darren> these machines, but somebody has to keep the HP service guys
>   Darren> clued up on old technology. The last guy that payed us a
>   Darren> visit though he was in a museum.
> 
> Heh.. ;-)
> 
> There is no need to feel apologetic though: the Intel Tiger platform
> should have the same issue.
> 
> 	--david
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
