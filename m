Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04A10C7EE29
	for <linux-ia64@archiver.kernel.org>; Sun,  4 Jun 2023 21:34:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229680AbjFDVeZ (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Sun, 4 Jun 2023 17:34:25 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36870 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229449AbjFDVeY (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Sun, 4 Jun 2023 17:34:24 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5A1CDBD;
        Sun,  4 Jun 2023 14:34:23 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id D167560282;
        Sun,  4 Jun 2023 21:34:22 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 34A8EC4339E;
        Sun,  4 Jun 2023 21:34:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1685914462;
        bh=fzDr5c6x/wpGz5MaedKnthfNfy7oxM2Pe1S5Md3YUN0=;
        h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
        b=SM2ymvrGVbvFukgI1II4Cl786xUgEXxaZwhyMkNx9XC9HOwlmcemHajWd5dJIw27g
         K5Q2qVehlAk82g2FMv4oSyqL8JQI0TfHu2kcMDVBQNDbERbPU7namEfIBziRkK/W8R
         JbStxMfXk2A/FunYVnxJ4utNw1XSfdf4KF75p5p0y1/aZhnE8L2PurFw/r4ZQx+TuE
         ZGcszb3beRvnnlyPmnxiEV6kA2I5oM6Xbmls711KnBDUMQyRb5P0PmTjK79NSpaAZT
         ITmN5TIweQFDLI64B+lz7iWFb4O41014HeAfSHZEihfTNJR5hL7kLLjf5gJ2n5obAO
         JlrczmFnk/O+w==
Received: by mail-lj1-f173.google.com with SMTP id 38308e7fff4ca-2b1bb2fc9c6so18839431fa.0;
        Sun, 04 Jun 2023 14:34:22 -0700 (PDT)
X-Gm-Message-State: AC+VfDy0gKu+kujOGrYxF6+Pv+giYp2m5Pkr0wnZHBIA+XOTARloHKBg
        9c2cZNldqcmaTw60g5wINt3SQsP/N0qHPA1ZAJA=
X-Google-Smtp-Source: ACHHUZ5kpTPqiGkWbOjSDfKjbBUNnSlkuVliBG/VOgmO/uQAEvxDvM1yhYeRiByxerPsU37VMLC73uEBvJBbh9inhxk=
X-Received: by 2002:a2e:3102:0:b0:2a8:ae90:83d6 with SMTP id
 x2-20020a2e3102000000b002a8ae9083d6mr3281869ljx.48.1685914460194; Sun, 04 Jun
 2023 14:34:20 -0700 (PDT)
MIME-Version: 1.0
References: <20230528230041.2592309-1-song@kernel.org> <5f4a62ad-fc8f-8738-40aa-f97b01898ac5@web.de>
In-Reply-To: <5f4a62ad-fc8f-8738-40aa-f97b01898ac5@web.de>
From:   Song Liu <song@kernel.org>
Date:   Sun, 4 Jun 2023 14:34:08 -0700
X-Gmail-Original-Message-ID: <CAPhsuW5Udq085+kAmYC+g3BXKgqJVnb1b3ZQabjmme4hqnshgw@mail.gmail.com>
Message-ID: <CAPhsuW5Udq085+kAmYC+g3BXKgqJVnb1b3ZQabjmme4hqnshgw@mail.gmail.com>
Subject: Re: [PATCH] module: fix module load for ia64
To:     Frank Scheiner <frank.scheiner@web.de>
Cc:     linux-modules@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-alpha@vger.kernel.org, debian-ia64@lists.debian.org,
        mcgrof@kernel.org, glaubitz@physik.fu-berlin.de,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "debian-alpha@lists.debian.org" <debian-alpha@lists.debian.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

On Sat, Jun 3, 2023 at 6:30=E2=80=AFAM Frank Scheiner <frank.scheiner@web.d=
e> wrote:
>
> On 29.05.23 01:00, Song Liu wrote:
> > Frank reported boot regression in ia64 as:
> >
> > ELILO v3.16 for EFI/IA-64
> > ..
> > Uncompressing Linux... done
> > Loading file AC100221.initrd.img...done
> > [    0.000000] Linux version 6.4.0-rc3 (root@x4270) (ia64-linux-gcc
> > (GCC) 12.2.0, GNU ld (GNU Binutils) 2.39) #1 SMP Thu May 25 15:52:20
> > CEST 2023
> > [    0.000000] efi: EFI v1.1 by HP
> > [    0.000000] efi: SALsystab=3D0x3ee7a000 ACPI 2.0=3D0x3fe2a000
> > ESI=3D0x3ee7b000 SMBIOS=3D0x3ee7c000 HCDP=3D0x3fe28000
> > [    0.000000] PCDP: v3 at 0x3fe28000
> > [    0.000000] earlycon: uart8250 at MMIO 0x00000000f4050000 (options
> > '9600n8')
> > [    0.000000] printk: bootconsole [uart8250] enabled
> > [    0.000000] ACPI: Early table checksum verification disabled
> > [    0.000000] ACPI: RSDP 0x000000003FE2A000 000028 (v02 HP    )
> > [    0.000000] ACPI: XSDT 0x000000003FE2A02C 0000CC (v01 HP     rx2620
> > 00000000 HP   00000000)
> > [...]
> > [    3.793350] Run /init as init process
> > Loading, please wait...
> > Starting systemd-udevd version 252.6-1
> > [    3.951100] ------------[ cut here ]------------
> > [    3.951100] WARNING: CPU: 6 PID: 140 at kernel/module/main.c:1547
> > __layout_sections+0x370/0x3c0
> > [    3.949512] Unable to handle kernel paging request at virtual addres=
s
> > 1000000000000000
> > [    3.951100] Modules linked in:
> > [    3.951100] CPU: 6 PID: 140 Comm: (udev-worker) Not tainted 6.4.0-rc=
3 #1
> > [    3.956161] (udev-worker)[142]: Oops 11003706212352 [1]
> > [    3.951774] Hardware name: hp server rx2620                   , BIOS
> > 04.29
> > 11/30/2007
> > [    3.951774]
> > [    3.951774] Call Trace:
> > [    3.958339] Unable to handle kernel paging request at virtual addres=
s
> > 1000000000000000
> > [    3.956161] Modules linked in:
> > [    3.951774]  [<a0000001000156d0>] show_stack.part.0+0x30/0x60
> > [    3.951774]                                 sp=3De000000183a67b20
> > bsp=3De000000183a61628
> > [    3.956161]
> > [    3.956161]
> >
> > which bisect to module_memory change [1].
> >
> > Debug showed that ia64 uses some special sections:
> >
> > __layout_sections: section .got (sh_flags 10000002) matched to MOD_INVA=
LID
> > __layout_sections: section .sdata (sh_flags 10000003) matched to MOD_IN=
VALID
> > __layout_sections: section .sbss (sh_flags 10000003) matched to MOD_INV=
ALID
> >
> > All these sections are loaded to module core memory before [1].
> >
> > Fix ia64 boot by loading these sections to MOD_DATA (core rw data).
> >
> > [1] commit ac3b43283923 ("module: replace module_layout with module_mem=
ory")
> >
> > Fixes: ac3b43283923 ("module: replace module_layout with module_memory"=
)
> > Reported-by: Frank Scheiner <frank.scheiner@web.de>
> > Closes: https://lists.debian.org/debian-ia64/2023/05/msg00010.html
> > Closes: https://marc.info/?l=3Dlinux-ia64&m=3D168509859125505
> > Cc: Linus Torvalds <torvalds@linux-foundation.org>
> > Signed-off-by: Song Liu <song@kernel.org>
> > ---
> >   kernel/module/main.c | 4 ++--
> >   1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/kernel/module/main.c b/kernel/module/main.c
> > index b4c7e925fdb0..9da4b551321e 100644
> > --- a/kernel/module/main.c
> > +++ b/kernel/module/main.c
> > @@ -1521,14 +1521,14 @@ static void __layout_sections(struct module *mo=
d, struct load_info *info, bool i
> >               MOD_RODATA,
> >               MOD_RO_AFTER_INIT,
> >               MOD_DATA,
> > -             MOD_INVALID,    /* This is needed to match the masks arra=
y */
> > +             MOD_DATA,
> >       };
> >       static const int init_m_to_mem_type[] =3D {
> >               MOD_INIT_TEXT,
> >               MOD_INIT_RODATA,
> >               MOD_INVALID,
> >               MOD_INIT_DATA,
> > -             MOD_INVALID,    /* This is needed to match the masks arra=
y */
> > +             MOD_INIT_DATA,
> >       };
> >
> >       for (m =3D 0; m < ARRAY_SIZE(masks); ++m) {
>
> Just want to add another observation (though not strictly ia64 but I
> wanted to keep the context):
>
> Testing showed that this patch also fixes module loading for alpha
> (tested on an AlphaServer DS25 w/v6.4-rc4 w/ and w/o the patch applied).

Thanks for this information!

I noticed alpha and ia64 are the only two archs to define ARCH_SHF_SMALL.
Other archs shouldn't see change with this.

Best,
Song
