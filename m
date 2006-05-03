From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 03 May 2006 11:15:04 +0000
Subject: Re: [RFC 2/3] LVHPT - Setup LVHPT
Message-Id: <445890B8.9050506@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060502052557.8990.87273.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20060502052557.8990.87273.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ian Wienand schrieb:

>On Wed, May 03, 2006 at 10:07:35AM +0200, Christian Hildner wrote:
>  
>
>>Yes. So why not picking up Ken's idea of two parallel IVTs.
>>    
>>
>
>I have a version of this, which I've tried to post here but I think
>the size limit here is very low.  It made it through to linux-mm
>
>http://marc.theaimsgroup.com/?l=linux-mm&m4664224732618&w=2
>
>or the patches are at
>
>http://www.gelato.unsw.edu.au/~ianw/lvhpt/patches/v2
>
>It generates ivt.S using a little script.  Any feedback on this
>approach welcome.
>
Ian,

I suggested a solution without having any script at all instead working 
with something like ivt.h containing macros for all common code and 
ivt_svhpt.S and ivt_lvhpt.S in parallel for specific code. It just might 
be more readable than your approach and both ways would be treated equal 
by the make process. Technically they are the same.

Christian

