From: Michael Madore <mmadore@turbolinux.com>
Date: Fri, 23 Feb 2001 19:20:00 +0000
Subject: Re: [Linux-ia64] Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005193@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005175@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005175@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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

