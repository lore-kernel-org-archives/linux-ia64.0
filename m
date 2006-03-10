From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 10 Mar 2006 17:11:52 +0000
Subject: Re: Fix race in the accessed/dirty bit handlers
Message-Id: <4411B358.2000003@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:

>>	itc.d	r25
>>	;;
>>	srlz.d
>>	ld8	r18 = [r17]
> 
> But it does not matter to the "ld8 r18 = [r17]" whether the "itc.d"
> is visible or not.  r17 cannot be in the virtual address range that
> will be affected by the itc.d, so the serialization here would just
> slow things down, and have no effect at all.

I did say:

>> No, we are not going to use the freshly inserted translation for the next "ld". <<

Please consider the second issue I mentioned about the "itc":
Making sure that an external purge request will not be missed by our new
translation. See also on page 3:127:

"The visibility of the itc instruction to generated purges (ptc.g, ptc.ga) must occur before subsequent memory operations. From a software perspective, this is similar to acquire semantics. Serialization is still required to observe the side-effects of the translation being present."

How to tell if this "visibility of the itc instruction to generated purges"
has already been established?

I think a ";;" is not enough, this is why I propose this sequence:

    itc.d    r25
    ;;
    srlz.d
    ld8    r18 = [r17]

Thanks,

Zoltan
