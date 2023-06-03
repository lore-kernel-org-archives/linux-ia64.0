Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 522F0C77B7A
	for <linux-ia64@archiver.kernel.org>; Sat,  3 Jun 2023 13:30:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229520AbjFCNah (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Sat, 3 Jun 2023 09:30:37 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48048 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229460AbjFCNag (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Sat, 3 Jun 2023 09:30:36 -0400
Received: from mout.web.de (mout.web.de [212.227.17.12])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 054D7CE;
        Sat,  3 Jun 2023 06:30:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=web.de;
 s=s29768273; t=1685799015; x=1686403815; i=frank.scheiner@web.de;
 bh=phjA+nmNE3l71re7CtGjToIKaQ5hp2OqTxz/uBCnkWg=;
 h=X-UI-Sender-Class:Date:Subject:To:Cc:References:From:In-Reply-To;
 b=VDws9qe+V2odFUEUykDljSRyPZLunNG+Tk8iz+hUSUyYimvXH3NLoSLTElPOH8JTzA2GD7m
 99LcslxTV4UsrEJXfm9ZTdnJaT0RnFoGtmMdPIyGEMAdCx5R7WQC8Kq3OMkcqAVCBqciywoVC
 MFnarAiuEnMtzNACKiNfjSi5CisPtJCy21FmwxsEekzNNGoTQMoSUO1ohQkx4TeLMqbTI+JhZ
 3BxEoiHboo5RDbj6Qzaa44nSF6AbNp1b+qujvv+tDo4o7tGlYSWpOj2u0G+VrvrKMSJmdmJwf
 Nur8o7DPYdd1aRUt6dCjmEzsazydfOsDalxXoIhlbsarPaAJKNww==
X-UI-Sender-Class: 814a7b36-bfc1-4dae-8640-3722d8ec6cd6
Received: from [192.168.178.30] ([79.200.215.18]) by smtp.web.de (mrweb106
 [213.165.67.124]) with ESMTPSA (Nemesis) id 1Mcpuy-1qeEBY3bvu-00Zkql; Sat, 03
 Jun 2023 15:30:14 +0200
Message-ID: <5f4a62ad-fc8f-8738-40aa-f97b01898ac5@web.de>
Date:   Sat, 3 Jun 2023 15:30:13 +0200
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.11.0
Subject: Re: [PATCH] module: fix module load for ia64
Content-Language: en-US
To:     Song Liu <song@kernel.org>, linux-modules@vger.kernel.org,
        linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org
Cc:     debian-ia64@lists.debian.org, mcgrof@kernel.org,
        glaubitz@physik.fu-berlin.de,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "debian-alpha@lists.debian.org" <debian-alpha@lists.debian.org>
References: <20230528230041.2592309-1-song@kernel.org>
From:   Frank Scheiner <frank.scheiner@web.de>
In-Reply-To: <20230528230041.2592309-1-song@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:1gPO6+JnLcXvpKB5CZT2YDT8gNSqDq44Bfn7eHujJCs6qgNUsqz
 HylIUclFiEhVauREMaU9F9f8BiehPJlZncm21oO9oCjc8Xfprq49ByB4yjg0/LRroWB8KtP
 TfFMyC50ap0tSPCn3W20ND0JcL/pFOeFhOfx5V9BvvqEkiGVKCYmaK963pv+NC2JRbUlTKQ
 B10VloeIQ6Lwli5u9nSPg==
UI-OutboundReport: notjunk:1;M01:P0:79u77PvV7tc=;9n0FfIwwwEMAcLhLF7SKbUk+pBP
 kRshBpYO8aNrC215K9XX1SPM+TceYVK9NWL8vLgvoD16gPzp7iclK3LD5/ntNAwX92RBCm573
 BASRyuWokYgl9xn6wrfULi18bCEAYGPy9lwt2EH+7CNPZSkZlqoERatsVYWxvn+2El345Ul1T
 nHy/Qfz1zJ2EbKFicjpqqQLNxVbjfoWtKu/dAvIDNLC31XngjaHATFbctJogdhHCrbFvB3JBi
 3GYED9S6yyuh5CFGSNY2XHG350nDU6vm13BpItuR4RPjlqPBrk613GgiqGNrubDWipX6w9tJB
 SohzYeTsIJeajmElpVm/8KuI9MJUNaPvw4Q9TubvnIJx72/2KvJZtv40thsPiMSlzGX8vQ/cY
 Yya98v4PQj7v6K+B+KIjUCOG4kM+8nplfCHZKo9CqXLpk5QUkN0dlt/ZRc/75Igj42xQXixJn
 tTr9Ag/CV+ChZvuREKPtEmXOMnt8Y4WeSz9bQxXJJDI6gfK7GsupZgmfRqUPAxxw6L1Llob8V
 waNQkrEEqL7QxlewzAMra9EDxTGBXtZ+dRKwa+jKjG52+fOtPa0tP/QyFdNymsa2PwOIhLWcp
 jLMIeT/s5DroM5vxNyF8CE6+R2oklzxWY8cmV4qyOgy2LixiQ0suHvp2ntvv0FxzZbpWEgKYM
 B1IPpKjMZoTB24h4JPzjH9+ey9/P7tIrxHLwnz2xcQ0oZja+DgtdzNA2sHL4IH7fG8beFuE14
 OXV/dEGwpuB8eCjqLNId/18QDrJX7pHZNCceU6fEPKQ/5IZHvcS00E9YLx9CUgc+zm/X5J8Os
 JXD8AUSQlPYVifdNqzYkVinzh4RrqckeVLxIsvhkh1bFwdltPLUSo3DOL1xA1kopKyIHYRqX0
 FLQAJZrU2g71wQYr0pjsbw2Ig1ndDZS+wpJwmHwkROhTP2/oZnN7KHaneJNzI8F9Ir7uRfPpf
 bpAhGJqnBnnrWd/P0a5JKfJoXMk=
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

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

Just want to add another observation (though not strictly ia64 but I
wanted to keep the context):

Testing showed that this patch also fixes module loading for alpha
(tested on an AlphaServer DS25 w/v6.4-rc4 w/ and w/o the patch applied).

Cheers,
Frank
