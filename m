From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Tue, 24 Feb 2004 09:45:35 +0000
Subject: Re: [BUG] 2.6.3 Slab corruption: errors are triggered when memory exceeds 2GB
Message-Id: <20040224094535.GC993@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040224002237.GE8906@cse.unsw.EDU.AU> <9D9A80A2-6689-11D8-82A4-000A95C5F2BE@ouray.cudenver.edu>
In-Reply-To: <9D9A80A2-6689-11D8-82A4-000A95C5F2BE@ouray.cudenver.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Josh Cady <jdcady@ouray.cudenver.edu>
Cc: LKML <linux-kernel@vger.kernel.org>, Ia64 Linux <linux-ia64@vger.kernel.org>

Hi Josh

Yes this machine has the replacement processor as of about 3 months ago
when the old replacement died, due to excessive heat.

Thanks
Darren


On Mon, 23 Feb 2004, Josh Cady wrote:

> Have you already had your recalled processors replaced by HP?  
> Following the replacement of the processors on my i2000 I've had better 
> luck with the 82 lb. beast, but never experienced the error you 
> mentioned to begin with.
> 
> Josh Cady
> jdcady@ouray.cudenver.edu
> 
> On Feb 23, 2004, at 5:22 PM, Darren Williams wrote:
> 
> >
> >On Ia64 Itanium 1 machines with more than 2.5GB of RAM the follwing 
> >error is triggered.
> >
> >slab error in check_poison_obj(): cache `size-16384': object was 
> >modified after freeing
> >
> >The machine that triggered the error above is an
> >
> >i2000 HP workstation
> >4gb RAM
> >1gb SWAP
> >
> >An identical machine with 2.5GB ram produces:
> >
> >slab error in check_poison_obj(): cache `size-2048': object was 
> >modified after freeing
> >
> >if the amount of RAM is reduced to 2GB or less then the errors do not 
> >appear.
> >
> >Kernel logs and configs can be found at:
> >http://quasar.cse.unsw.edu.au/~dsw/public-files/lemon-debug/
> >
> >
> >--------------------------------------------------
> >Darren Williams <dsw AT gelato.unsw.edu.au>
> >Gelato@UNSW <www.gelato.unsw.edu.au>
> >--------------------------------------------------
> >-
> >To unsubscribe from this list: send the line "unsubscribe 
> >linux-kernel" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >Please read the FAQ at  http://www.tux.org/lkml/
> >
--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
