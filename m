From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Fri, 18 Mar 2005 01:31:12 +0000
Subject: Re: recent fix for pgd_addr_end
Message-Id: <16954.12128.786768.694470@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
In-Reply-To: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Tony Luck <Luck> writes:

Tony> Peter, Dave, and anyone else following along: How does this look
Tony> (ignoring for the moment the usage of pgd_addr_end() in the
Tony> vmalloc() code path for region 5 ... I'll deal with that next,
Tony> but for the moment it is only a theoretical problem as we don't
Tony> map anywhere close to enough things in region 5 to trigger the
Tony> IA64_PGD_OVERFLOW path in this code).

I think it's good.  It even boots :-)

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
