From: Russ Anderson <rja@sgi.com>
Date: Fri, 06 Aug 2004 15:47:34 +0000
Subject: Re: Altix I/O code reorganization
Message-Id: <200408061547.i76FlY8U009151@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20040806141836.A9854@infradead.org> from "Christoph Hellwig" at Aug 06, 2004 02:18:36 PM
References: <200408042014.i74KE8fD141211@fsgi900.americas.sgi.com>
In-Reply-To: <200408042014.i74KE8fD141211@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: Pat Gefre <pfg@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Christoph Hellwig wrote:
> 
> 006-bte:
>   Please merge bte_error.c into the existing bte.c

bte_crb_error_handler() is called from hubiio_crb_error_handler()
in arch/ia64/sn/io/sn2/shuberror.c.  That's why bte_error.c is
in the same directory as shuberror.c (and not in arch/ia64/sn/kernel
with bte.c).

If bte_error.c is merged, wouldn't it make more sense to
merge it with shuberror.c?

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
