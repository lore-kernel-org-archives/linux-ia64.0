From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Fri, 01 Feb 2008 03:37:48 +0000
Subject: RE: [kvm-ia64-devel] [PATCH][02] Change srlz.d to srlz.i foria64_set_psr
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD321B8@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCD31FC5@pdsmsx415.ccr.corp.intel.com> <B5C8647CF5836Dtakebe_akio@jp.fujitsu.com>
In-Reply-To: <B5C8647CF5836Dtakebe_akio@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akio Takebe <takebe_akio@jp.fujitsu.com>, Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>
Cc: kvm-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, kvm-ia64-devel@lists.sourceforge.net

Akio Takebe wrote:
> Hi, Xiantao
> 
>> void __init
>> diff --git a/include/asm-ia64/processor.h
>> b/include/asm-ia64/processor.h index be3b0ae..038642f 100644 ---
>> a/include/asm-ia64/processor.h +++ b/include/asm-ia64/processor.h
>> @@ -472,7 +472,7 @@ ia64_set_psr (__u64 psr)
>> {
>> 	ia64_stop();
>> 	ia64_setreg(_IA64_REG_PSR_L, psr);
>> -	ia64_srlz_d();
>> +	ia64_srlz_i();
>> }
> Why do you remove ia64_srlz_d()?
> We should need srlz.d if we change PSR bits(e.g. PSR.dt and so on).
> Does srlz.i do also date serialization?
Hi, Akio
Srlz.i  implicitly ensures srlz.d  per SDM.  
Thanks
Xiantao

