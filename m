From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Fri, 23 Feb 2001 19:48:36 +0000
Subject: RE: [Linux-ia64] Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005194@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005175@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005175@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

For stablity on earlier steppings CONFIG_ITANIUM_PTCG not set,
CONFIG_DISABLE_VHPT=y, CONFIG_ITANIUM_BSTEP_SPECIFIC =y
CONFIG_ITANIUM_B[012]_SPECIFIC should be = y
-----Original Message-----
From: Michael Madore [mailto:mmadore@turbolinux.com]
Sent: Friday, February 23, 2001 11:20 AM
To: Seth, Rohit
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] Re: Lockups on 2.4.1


What is the recommendation for earlier B steppings?

On Fri, Feb 23, 2001 at 11:06:53AM -0800, Seth, Rohit wrote:
> Just want to add that if you are running on B3 then you should have
> CONFIG_ITANIUM_PTCG=y and CONFIG_DISABLE_VHPT not set. 
> 
> -----Original Message-----
> From: Jun Nakajima [mailto:jun@sco.com]
> Sent: Friday, February 23, 2001 7:20 AM
> To: Jack Steiner
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] Re: Lockups on 2.4.1
> 
> 
> This might explain why I was _not_ able to reproduce such a hang after
> overnight stress tests on a 4-way Lion... My configuration has
> CONFIG_ITANIUM_PTCG=y, and flush_tlb_no_ptcg() is never called by
> flush_tlb_range() if it's defined. 
> 
> 

-- 
Mike Madore
Software Engineer
TurboLinux, Inc.

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


