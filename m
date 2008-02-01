From: Akio Takebe <takebe_akio@jp.fujitsu.com>
Date: Fri, 01 Feb 2008 03:58:09 +0000
Subject: Re: [kvm-ia64-devel] [PATCH][02] Change srlz.d to srlz.iforia64_set_psr
Message-Id: <B6C86486A84071takebe_akio@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCD31FC5@pdsmsx415.ccr.corp.intel.com>
	<B5C8647CF5836Dtakebe_akio@jp.fujitsu.com>
	<42DFA526FC41B1429CE7279EF83C6BDCD321B8@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCD321B8-wq7ZOvIWXbMAbVU2wMM1CrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Xu, Anthony" <anthony.xu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Akio Takebe <takebe_akio-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-ia64-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

Hi, Xiantao

>> Why do you remove ia64_srlz_d()?
>> We should need srlz.d if we change PSR bits(e.g. PSR.dt and so on).
>> Does srlz.i do also date serialization?
>Hi, Akio
>Srlz.i  implicitly ensures srlz.d  per SDM.  
OK, thanks.

Best Regards,

Akio Takebe

