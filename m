From: Akio Takebe <takebe_akio@jp.fujitsu.com>
Date: Fri, 01 Feb 2008 02:48:43 +0000
Subject: Re: [kvm-ia64-devel] [PATCH][02] Change srlz.d to srlz.i foria64_set_psr
Message-Id: <B5C8647CF5836Dtakebe_akio@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCD31FC5@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCD31FC5-wq7ZOvIWXbMAbVU2wMM1CrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Xu, Anthony" <anthony.xu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-ia64-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

Hi, Xiantao

> void __init
>diff --git a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
>index be3b0ae..038642f 100644
>--- a/include/asm-ia64/processor.h
>+++ b/include/asm-ia64/processor.h
>@@ -472,7 +472,7 @@ ia64_set_psr (__u64 psr)
> {
> 	ia64_stop();
> 	ia64_setreg(_IA64_REG_PSR_L, psr);
>-	ia64_srlz_d();
>+	ia64_srlz_i();
> }
Why do you remove ia64_srlz_d()?
We should need srlz.d if we change PSR bits(e.g. PSR.dt and so on).
Does srlz.i do also date serialization?

Best Regards,

Akio Takebe

