From: Russ Anderson <rja@sgi.com>
Date: Mon, 17 Jan 2005 21:07:21 +0000
Subject: Re: [patch] Remove limit on MCA recoveries
Message-Id: <200501172107.j0HL7LVq3017377@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
In-Reply-To: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hidetoshi Seto wrote:
> 
> This array is temporary designed for future use.
> Similar to what Keith said, the array would be helpful if
> something like dump application have no idea to avoid reading
> MCA pages.

I agree with that functionality, but think that using new
page->flags types would be a better implementation.

If page->flags are used to achieve that functionality, would
you object to removing the array?  Or is there additional data
that should be added to the array?

My only real complaint about the array is that the current size
is too small.  The Altix error injection test (which can modify
the ECC to create true memory uncorrectables) can recover from 
several hundred memory uncorrectable errors, when the array 
limitation is removed.  Making the array dynamic (linked list or 
something), so the size can be expanded would be a sufficient 
solution, too.
 
> Roughly say, traditionally there are 2 type of pages:
>   1 - not reserved
>   2 - reserved
> IMHO, there should be additional 3 type:
>   3 - MCA reserved, not classified, don't read
>   4 - Hard error (e.g. page on broken DIMM)
>   5 - Soft error (e.g. having poisoned data)
> 
> The MCA recovery driver just does isolation.
> What the driver want to do is marking 3 to the MCA pages.
> 
> It would better if type 3 pages could be classified into 4 or 5,

Yes.  Or just classify any that are not know to be 5 as 4 (assume
the worst classification unless sure it is a less sever classification).
That would remove the need for type 3.  

> and more better if type 5 pages could be recycled into the system.

Poison data can be cleaned up on Altix.  Those pages should not
be marked "reserved".  They should have the poison data cleaned up
and the pages reused, since the memory itself is not broken.  All
that is needed is the code to do it.  :-)

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
