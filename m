From: Andreas Hirstius <Andreas.Hirstius@cern.ch>
Date: Wed, 06 Apr 2005 07:34:41 +0000
Subject: Re: [Gelato-technical] Serious performance degradation on a RAID
Message-Id: <42539111.20707@cern.ch>
List-Id: <linux-ia64.vger.kernel.org>
References: <16978.62532.841151.100745@napali.hpl.hp.com>
In-Reply-To: <16978.62532.841151.100745@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



David Mosberger wrote:

>>>>>>On Wed, 06 Apr 2005 09:29:59 +0200, Andreas Hirstius <Andreas.Hirstius@cern.ch> said:
>>>>>>            
>>>>>>
>
>  Andreas> Because of this strange correlation between block size and
>  Andreas> page size and the fact, that I don't see a problem on x86 I
>  Andreas> suspected an ia64-specific problem. My "favourite"
>  Andreas> candidate is the conversion to 4 level pagetables between
>  Andreas> 2.6.10-bk6 and 2.6.10-bk7.
>
>That's certainly a possibility.  But didn't you say the problem also
>occurred when using 4KB page size on ia64?
>
>  
>
Yes, the problem appears at any page size...


Andreas

>	--david
>
>  
>
