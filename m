From: "Liu, Benjamin" <benjamin.liu@intel.com>
Date: Mon, 08 Mar 2004 07:44:16 +0000
Subject: RE: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <3ACA40606221794F80A5670F0AF15F8401B1A017@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Grant Grundler <iod00d@hp.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Grant,

Both ISA and PCI device drivers would call arch/ia64/kernel/irq.c:request_i=
rq()-->arch/ia64/kernel/irq.c:setup_irq() -->arch/ia64/kernel/iosapic.c:ios=
apic_startup_level_irq() or  arch/ia64/kernel/iosapic.c:iosapic_startup_edg=
e_irq() function to unmask the IRQ. I believe the ISA can be handled gracef=
ully, if any.

ISA is legacy to IA64. The configuration script of 2.4.23 has CONFIG_ISA of=
f explicitly for IA64, 2.6.2 doesn't have this option for IA64. I just wond=
er whether the legacy probing method still exists on IA64.

Thanks,
Pingping (Benjamin) Liu
Intel China Software Center


>-----Original Message-----
>From: linux-ia64-owner@vger.kernel.org=20
>[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Grant Grundler
>Sent: 2004=C4=EA3=D4=C28=C8=D5 14:31
>To: Kenji Kaneshige
>Cc: linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org
>Subject: Re: [PATCH] fix PCI interrupt setting for ia64
>
>
>On Mon, Mar 08, 2004 at 11:49:10AM +0900, Kenji Kaneshige wrote:
>> In ia64 kernel, IOSAPIC's RTEs for PCI interrupts are unmasked at the
>> boot time before installing device drivers. I think it is=20
>very dangerous.
>
>Hi Kenji,
>I think this behavior exists to support "legacy" IRQ probing.
>I'm wondering if it would be sufficient to wrap the patch in
>"#ifndef CONFIG_ISA" or something like that.
>
>grant
>-
>To unsubscribe from this list: send the line "unsubscribe=20
>linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
