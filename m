From: Jes Sorensen <jes@sgi.com>
Date: Fri, 25 Jan 2008 08:39:29 +0000
Subject: Re: [kvm-devel] ia64 kernel patches?
Message-Id: <4799A041.6070808@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4798C34F.9010509@sgi.com>
	<20080124185316.GW3627@sequoia.sous-sol.org>
	<42DFA526FC41B1429CE7279EF83C6BDCCE708C@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCCE708C-wq7ZOvIWXbMAbVU2wMM1CrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>, kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Zhang, Xiantao wrote:
> Hi, Jes
> Yes, Anthony and I are working with kernel-ia64 and kvm community to push the patches. Since kernel should export some interface for kvm use, we have to wait the response from kernel-ia64. But anyway,  It should be picked up in near future. :)  Compared with last push, we added smp guest support and got more stable status now . 
> Thanks
> Xiantao

Hi Xiantao,

If you could put up the patches somewhere, I could
help you clean them up and push them. I would prefer not
to wait until they appear in Linus' tree if possible.

Cheers,
Jes


> 
> -----Original Message-----
> From: Chris Wright [mailto:chrisw@sous-sol.org] 
> Sent: 2008年1月25日 2:53
> To: Jes Sorensen
> Cc: Zhang, Xiantao; kvm-devel@lists.sourceforge.net
> Subject: Re: [kvm-devel] ia64 kernel patches?
> 
> * Jes Sorensen (jes@sgi.com) wrote:
>> Trying to browse the list archives, but both gmane and sourcefrog's
>> interfaces are really painful to deal with.
>>
>> So, any chance someone could point me at the current ia64 KVM kernel
>> patches? I notice they are not yet in Avi's tree.
> 
> The last full round of patches I recall are from December.
> Maybe better to get updated patches from Xiantao?
> 
> thanks,
> -chris

