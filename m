From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 10 Mar 2006 10:40:18 +0000
Subject: Re: Fix race in the accessed/dirty bit handlers
Message-Id: <44115792.6080708@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christian Hildner wrote:
> Zoltan Menyhart schrieb:
> 
>> The only instruction I know of to synchronize with the "itc" mechanism is
>> the "srlz" instruction. 
> 
> 
> rfi implies srlz.i (and srlz.d) as well.

You are right as far as the user mode code is concerned.

Yet, we have not got any "rfi" in our

    insert TLB
    ;;
    re-read

sequence. Only a "srlz" can help.:

	itc.d	r25
	;;
	srlz.d
	ld8	r18 = [r17]

Thanks,

Zoltan
