From: Andreas Hirstius <Andreas.Hirstius@cern.ch>
Date: Wed, 06 Apr 2005 07:29:59 +0000
Subject: Re: [Gelato-technical] Serious performance degradation on a RAID
Message-Id: <42538FF7.60404@cern.ch>
List-Id: <linux-ia64.vger.kernel.org>
References: <16978.62532.841151.100745@napali.hpl.hp.com>
In-Reply-To: <16978.62532.841151.100745@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



David Mosberger wrote:

>>>>>>On Tue, 05 Apr 2005 20:11:51 +0200, Andreas Hirstius <Andreas.Hirstius@cern.ch> said:
>>>>>>            
>>>>>>
>
>  Andreas> Hi, We have a rx4640 with 3x 3Ware 9500 SATA controllers
>  Andreas> and 24x WD740GD HDD in a software RAID0 configuration
>  Andreas> (using md).  With kernel 2.6.11 the read performance on the
>  Andreas> md is reduced by a factor of 20 (!!)  compared to previous
>  Andreas> kernels.  The write rate to the md doesn't change!! (it
>  Andreas> actually improves a bit).
>
>Is there any reason to believe this change in behavior is
>ia64-specific?  I doubt it.  The q-syscollect profiles on your
>web-site shows that the CPU is basically completely idle.  You may
>want to try 2.6.10 to see whether the bad behavior was introduced
>before or after that.  Unfortunately, 2.6 is developing very rapidly
>so you may have to do more binary searching between 2.6.9 and 2.6.10
>or 2.6.10 and 2.6.11 to pin the problem down to a useful granularity.
>You may also want to look at the bitkeeper changelogs to see if you
>can find anything suspicious (you can do that easily via the web by
>browsing the source code [1]).  Lastly, you may want to ask on
>linux-kernel whether anybody can think of a change that could have
>this effect.
>
>  
>
The problems started with 2.6.10-bk7...
(and I've tested 2.6.9, 2.6.10, 2.6.10-bk5 - -bk14,  2.6.11-rc[1-5], 
2.6.11, 2.6.11-mm[12], 2.6.12-rc[12])

The only other platform I have is a dual-xeon and I don't see the 
problem there (same controllers/disks)...

Because of this strange correlation between block size and page size and 
the fact, that I don't see a problem on x86 I suspected an ia64-specific 
problem. My "favourite" candidate is the conversion to 4 level 
pagetables between 2.6.10-bk6 and 2.6.10-bk7.


Andreas


>	--david
>
>[1] http://linux.bkbits.net:8080/linux-2.5/src?nav=index.html
>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>  
>
