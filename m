From: Andreas Hirstius <Andreas.Hirstius@cern.ch>
Date: Wed, 06 Apr 2005 18:57:39 +0000
Subject: Re: [Gelato-technical] Serious performance degradation on a RAID
Message-Id: <42543123.3080905@cern.ch>
List-Id: <linux-ia64.vger.kernel.org>
References: <16978.62532.841151.100745@napali.hpl.hp.com>
In-Reply-To: <16978.62532.841151.100745@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



David Mosberger wrote:

>>>>>>On Wed, 06 Apr 2005 10:33:07 +0200, Andreas Hirstius <Andreas.Hirstius@cern.ch> said:
>>>>>>            
>>>>>>
>
>  Andreas> But the driver in questions is 3w-9xxx and there have been
>  Andreas> no chances at all in this driver between 2.6.10 and
>  Andreas> 2.6.12-rc1. The changed driver in -rc2 still has the
>  Andreas> problem.  And I've tried the driver built-in and as a
>  Andreas> module (default)...
>
>Are you sure the problem is due to the driver and not RAID0?  What if
>you dd directly from the underlying device?
>
>  
>
To make sure it's not the md/raid I just took the driver/md directory 
from 2.6.9 and 2.6.10 and used it in 2.6.11 => no change in behaviour ...
(The changes in md.c are minor and there are no changes in raid0.c 
between .10 and .11 anyway)

As I say on the webpage, a dd on the underlying devices works fine...

It might still be a higher level interface to the md, that's wrong.

And I'm not saying that it's the 3w-9xx driver!! It hasn't changed 
between 2.6.10 and 2.6.11, so pretty much impossible to introduce bugs 
there...
(It was just mentioned wrt to the fusion-mpt driver.)

Andreas

>	--david
>
>  
>
