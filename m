From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Fri, 18 Mar 2005 02:35:20 +0000
Subject: Re: recent fix for pgd_addr_end
Message-Id: <20050318023520.GC30002@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
In-Reply-To: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Luck,

On Thu, 17 Mar 2005, Luck, Tony wrote:

> Peter, Dave, and anyone else following along:
> 
> How does this look (ignoring for the moment the usage of pgd_addr_end()
> in the vmalloc() code path for region 5 ... I'll deal with that next, but
> for the moment it is only a theoretical problem as we don't map anywhere
> close to enough things in region 5 to trigger the IA64_PGD_OVERFLOW path
> in this code).
> 
> -Tony
> 

Boots on 16way HP Olyimpia:)

[snip]

Thanks
Darren

--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
