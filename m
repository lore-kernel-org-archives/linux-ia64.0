From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 01 Mar 2005 15:24:20 +0000
Subject: Re: IA64 memory
Message-Id: <1109690660.6103.5.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <851caabb05020220513945437@mail.gmail.com>
In-Reply-To: <851caabb05020220513945437@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   The memory capacity of the zx1 chipset is much greater than the
amount that can be physically installed in the system.  I believe the
largest zx1 system so far is an rx5670, which supports 96GB w/ 2GB
DIMMs.  The sx1000 based systems can support more memory.

	Alex

On Tue, 2005-03-01 at 19:02 +0530, Vaibhav Sharma wrote:
> hi all, 
> 
> Thank you again for the details.
> 
> I have another query. I had downloaded a pdf concerning the zx1 memory
> and I/O ("zx1 mio External reference specification"). In the system
> address map, it shows that memory space is consisting of m0(1 GB),
> m1(3GB) and m2 (252 GB), which means  m0+m1+m2= 1+ 3+252%6 GB*. Is
> it that zx1 chip is capable of addressing RAM of 256 GB size only..if
> my RAM is more than 256 GB, do I have to change the chip..?
> 
> (* not considering other areas like GMMIO, LMMIO etc)..
> 
> I have zx6000 hp machine. 
> 
> Plz do reply...
> 
> TIA, 
> vaibhav

> 
-- 
Alex Williamson                             HP Linux & Open Source Lab

