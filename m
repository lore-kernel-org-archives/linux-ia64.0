Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B10FC7EE24
	for <linux-ia64@archiver.kernel.org>; Tue, 30 May 2023 20:33:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233486AbjE3Udu (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Tue, 30 May 2023 16:33:50 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:55860 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233509AbjE3Udd (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Tue, 30 May 2023 16:33:33 -0400
Received: from mout.web.de (mout.web.de [212.227.15.3])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 2E05A18F;
        Tue, 30 May 2023 13:33:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=web.de;
 s=s29768273; t=1685478709; x=1686083509; i=frank.scheiner@web.de;
 bh=zvKePYDs+XlnMbnTTeDD0lui6Yfozs8xOv8VaodYm/A=;
 h=X-UI-Sender-Class:Date:Subject:To:Cc:References:From:In-Reply-To;
 b=NmksC8G+6pbX+HwlEB7lm94jjk1t8YQxh7R4zWInbTqvs3FqOqgQ7Baoewr9Z4QJZ44sjJ3
 wm2ua/o92eNzmvhed5Yzhy3U7lBqfPP36Nr790HVaMTdGAUqhPortSIFnMzrhbb6/zcfe7lDK
 8rJeZpvwfCsEhBoDZJ22BFdArwGNMHLGxlbQUukOp7GHufeeUpfAYPafIgqz7j5guepIQtFgF
 oJFSGKlJMhPgcIe4Ea7zDeMWpqTVeZIWoP09rQc49y6+2JJA1nYYi1+Xye2rPSwME0l41Z3AC
 WPq5z+Ftm9UH9qZ34nyf0OJogtN+DectsqxPYBilWwexgpXZ52iQ==
X-UI-Sender-Class: 814a7b36-bfc1-4dae-8640-3722d8ec6cd6
Received: from [192.168.178.30] ([217.247.36.184]) by smtp.web.de (mrweb006
 [213.165.67.108]) with ESMTPSA (Nemesis) id 1MjxiW-1qWrF71kGO-00kdTn; Tue, 30
 May 2023 22:31:49 +0200
Message-ID: <4da53e7c-dc04-ab00-a921-0ea56191a868@web.de>
Date:   Tue, 30 May 2023 22:31:48 +0200
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.11.0
Subject: Re: [PATCH] module: fix module load for ia64
Content-Language: en-US
To:     Song Liu <song@kernel.org>, linux-modules@vger.kernel.org,
        linux-ia64@vger.kernel.org
Cc:     debian-ia64@lists.debian.org, mcgrof@kernel.org,
        glaubitz@physik.fu-berlin.de,
        Linus Torvalds <torvalds@linux-foundation.org>
References: <20230528230041.2592309-1-song@kernel.org>
From:   Frank Scheiner <frank.scheiner@web.de>
In-Reply-To: <20230528230041.2592309-1-song@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:s6QVptQcmzSGo30yvnxCB+Xg3nFGt0dWE3xxGCZHSfCjTehc/1X
 ySHk3MNzu5jL15VAzIOme5WoI2nePzr1SA2yCya5GQ8qD5AFyHS4e5mvkH4j0J4jUR2I0eh
 pENfQ3ydMV8kqnwdpAexlkk9Uw80oZrgQ/Al1DE1mPkmpsADa6lfOG/j1iYaL1AXt31SMXD
 wJ5YhLevBx2yrOQ2jvW/Q==
UI-OutboundReport: notjunk:1;M01:P0:5UawVaysicY=;q+HYN94O6yXeHy1Bv3ulbHa9k5E
 ivRiev3/USvGq9CBhsTt18k83ZeR2XB8ymP6WkaB3AuXEKkLra1Zhlrpv9csQ7YUtGcnmzHHB
 eQceGPCWHcy2Hos1JHjt7b0RNUlY7kMrgCik8CwbyTQ++aBX0/s17EXobHTUoWR+TZik04ipF
 S3QRfhvs0FrK2h0BuP8RJkMMHYeJoDJInorn6pgclYpQzLHd38bv1CQZDyaLjnTz486irqf04
 vY5qiKOv/WSKHBWWe9QCPjezdRlOvyOXMhqXVCYPquMTgSeNfdmLF+pkbX6iOJgdKE6BUKIQG
 +rUq1dWIXb8Lw9tox0OHDR6DUyUp7Tnj4MqvfwTqeqKnbFt459WfQqYWaeC+mBtCKBZ8wBXm6
 uogGsjg/+3eGOl5AvZQ2uMw0YqP8nDl2fiJ6dwA01am80c6z7W3nyXYlQSDX4RiCTrMf+y58p
 BgZ/mmgfdSc55KzVy9ptEW72IT9kW7AiG8difmYQTIi8Vg35/CBCr1dxAIEpd8s9Xyl2ZATbg
 TMMhM8uCcgetXBuk9KsizTMx+d58d5BoX2KULeC2GfaWtgQeg+xm616GCwqZCTDoHYRF43MEo
 ESp3uqMAS/GLSThTFBjE/r6S2BR96tcPIPZBGvIQ2qk5CF916PkWp+pNwYUK7WUvjI0muD0BE
 nR9ogERTm5B0Sf19F0wwxZe/T2yEyhLLWDc/ws4F/JgrudYEALV2DLMeFR0AhcaT4dNo09Lmu
 i46sp8m/BgaDdpkqIJbyeY4ww4O+r9MOoZY39iE67Eb2Lp8e+85W6wfmXKWR5EJA7IJ0mmv6N
 q1EFOS0Ii5N+PASl9fNWbEMJLXloTEbCgOprIUrIX1obqruoynAszfXf7mEOmS5Kfocyr0U/b
 SBvzmxD3FAeVuL1m0AW1snB/reE0UniOCo4+PKoYEzcvzOVidlknBD6tYiV905ebAivN7apeF
 vOX3jdF0GlJ6zeNtT+iTfk/hGmc=
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org
Message-ID: <20230530203148.u9arMh_tD1nnsbYCYD9OA_1E1OR5jF-m980axPKbwTM@z>

On 29.05.23 01:00, Song Liu wrote:
> Frank reported boot regression in ia64 as:
>
> ELILO v3.16 for EFI/IA-64
> ..
> Uncompressing Linux... done
> Loading file AC100221.initrd.img...done
> [    0.000000] Linux version 6.4.0-rc3 (root@x4270) (ia64-linux-gcc
> (GCC) 12.2.0, GNU ld (GNU Binutils) 2.39) #1 SMP Thu May 25 15:52:20
> CEST 2023
> [    0.000000] efi: EFI v1.1 by HP
> [    0.000000] efi: SALsystab=3D0x3ee7a000 ACPI 2.0=3D0x3fe2a000
> ESI=3D0x3ee7b000 SMBIOS=3D0x3ee7c000 HCDP=3D0x3fe28000
> [    0.000000] PCDP: v3 at 0x3fe28000
> [    0.000000] earlycon: uart8250 at MMIO 0x00000000f4050000 (options
> '9600n8')
> [    0.000000] printk: bootconsole [uart8250] enabled
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x000000003FE2A000 000028 (v02 HP    )
> [    0.000000] ACPI: XSDT 0x000000003FE2A02C 0000CC (v01 HP     rx2620
> 00000000 HP   00000000)
> [...]
> [    3.793350] Run /init as init process
> Loading, please wait...
> Starting systemd-udevd version 252.6-1
> [    3.951100] ------------[ cut here ]------------
> [    3.951100] WARNING: CPU: 6 PID: 140 at kernel/module/main.c:1547
> __layout_sections+0x370/0x3c0
> [    3.949512] Unable to handle kernel paging request at virtual address
> 1000000000000000
> [    3.951100] Modules linked in:
> [    3.951100] CPU: 6 PID: 140 Comm: (udev-worker) Not tainted 6.4.0-rc3=
 #1
> [    3.956161] (udev-worker)[142]: Oops 11003706212352 [1]
> [    3.951774] Hardware name: hp server rx2620                   , BIOS
> 04.29
> 11/30/2007
> [    3.951774]
> [    3.951774] Call Trace:
> [    3.958339] Unable to handle kernel paging request at virtual address
> 1000000000000000
> [    3.956161] Modules linked in:
> [    3.951774]  [<a0000001000156d0>] show_stack.part.0+0x30/0x60
> [    3.951774]                                 sp=3De000000183a67b20
> bsp=3De000000183a61628
> [    3.956161]
> [    3.956161]
>
> which bisect to module_memory change [1].
>
> Debug showed that ia64 uses some special sections:
>
> __layout_sections: section .got (sh_flags 10000002) matched to MOD_INVAL=
ID
> __layout_sections: section .sdata (sh_flags 10000003) matched to MOD_INV=
ALID
> __layout_sections: section .sbss (sh_flags 10000003) matched to MOD_INVA=
LID
>
> All these sections are loaded to module core memory before [1].
>
> Fix ia64 boot by loading these sections to MOD_DATA (core rw data).
>
> [1] commit ac3b43283923 ("module: replace module_layout with module_memo=
ry")
>
> Fixes: ac3b43283923 ("module: replace module_layout with module_memory")
> Reported-by: Frank Scheiner <frank.scheiner@web.de>
> Closes: https://lists.debian.org/debian-ia64/2023/05/msg00010.html
> Closes: https://marc.info/?l=3Dlinux-ia64&m=3D168509859125505
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Song Liu <song@kernel.org>
> ---
>   kernel/module/main.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/module/main.c b/kernel/module/main.c
> index b4c7e925fdb0..9da4b551321e 100644
> --- a/kernel/module/main.c
> +++ b/kernel/module/main.c
> @@ -1521,14 +1521,14 @@ static void __layout_sections(struct module *mod=
, struct load_info *info, bool i
>   		MOD_RODATA,
>   		MOD_RO_AFTER_INIT,
>   		MOD_DATA,
> -		MOD_INVALID,	/* This is needed to match the masks array */
> +		MOD_DATA,
>   	};
>   	static const int init_m_to_mem_type[] =3D {
>   		MOD_INIT_TEXT,
>   		MOD_INIT_RODATA,
>   		MOD_INVALID,
>   		MOD_INIT_DATA,
> -		MOD_INVALID,	/* This is needed to match the masks array */
> +		MOD_INIT_DATA,
>   	};
>
>   	for (m =3D 0; m < ARRAY_SIZE(masks); ++m) {

Tested to work on top of v6.4-rc4 fixing the boot regression for:

* rx4640 (w/Madison and zx1)
* rx2620 (w/Montecito and zx1)
* rx2660 (w/Montvale and zx2 - Adrian's rx2660 is with Montecito instead
IIRC, so I only tested on the one with Montvale processor)
* rx6600 (w/Montvale and zx2)
* rx2800 i2 (w/Tukwila)

Tested-by: Frank Scheiner <frank.scheiner@web.de>
