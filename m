From: Keith Owens <kaos@sgi.com>
Date: Thu, 02 Nov 2006 07:32:24 +0000
Subject: Re: [PATCH]IA64 trap code 16 bytes atomic copy on montecito, take 2
Message-Id: <23211.1162452744@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454961EE.4070608@intel.com>
In-Reply-To: <454961EE.4070608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"bibo,mao" (on Thu, 02 Nov 2006 15:27:34 +0800) wrote:
>Keith Owens wrote:
>> Keith Owens (on Thu, 02 Nov 2006 18:22:58 +1100) wrote:
>>> /me kicks himself for mixing up src and dest.
>>>
>>> extern ld16_st16(dest, src);
>>>
>>> ENTRY(ld16_st16)
>>> 	ld16 r15=[r32]		// src
>>> 	;;
>>> 	st16 [r33]=r15		// dest
>>> 	br.ret.sptk.many rp
>>> EXIT(ld16_st16)
>> 
>> Third time lucky, then it's time for some sleep.
>Thanks:), I do not whether ar.csd should be saved/restore across
>this function.

ar.csd is defined to be a scratch register.  So its contents do not
need to be saved.

>> extern ld16_st16(dest, src);
>> 
>> ENTRY(ld16_st16)
>> 	ld16 r15=[r33]		// src
>> 	;;
>> 	st16 [r32]=r15		// dest
>> 	br.ret.sptk.many rp
>> EXIT(ld16_st16)
>
>

