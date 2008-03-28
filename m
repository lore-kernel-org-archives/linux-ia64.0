From: Akio Takebe <takebe_akio@jp.fujitsu.com>
Date: Fri, 28 Mar 2008 14:40:34 +0000
Subject: Re: [17/17][PATCH] kvm/ia64: How to boot up guests on kvm/ia64
Message-Id: <8BC890E1ADECDFtakebe_akio@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EEF@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EEF@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>, Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Jes Sorensen <jes@sgi.com>, kv

Hi,

I found 3 typos.

>+3. Get Guest Firmware named as Flash.fd, and put it under right place:
>+	(1) If you have the guest firmware (binary)released by Intel
>Corp for Xen, you can use it directly.
>+	(2) If you want to build a guest firmware form souce code.
souce ---> source

>+5. Known possbile issue on some platforms with old Firmware
>+
possbile ---> possible

>+(2): Applying the below patch to kernel source.
>+diff --git a/arch/ia64/kernel/pal.S b/arch/ia64/kernel/pal.S
>+index 0b53344..f02b0f7 100644
>+--- a/arch/ia64/kernel/pal.S
>++++ b/arch/ia64/kernel/pal.S
>+@@ -84,7 +84,8 @@ GLOBAL_ENTRY(ia64_pal_call_static)
>+ 	mov ar.pfs = loc1
>+ 	mov rp = loc0
>+ 	;;
>+-	srlz.d				// seralize restoration of psr.l
>++	srlz.i			// seralize restoration of psr.l
seralize ---> serialize

Best Regards,

Akio Takebe

