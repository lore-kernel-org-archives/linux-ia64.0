From: "Liu, Benjamin" <benjamin.liu@intel.com>
Date: Thu, 11 Mar 2004 08:32:57 +0000
Subject: RE: 2.6.3 compilation problem
Message-Id: <3ACA40606221794F80A5670F0AF15F8401B1A05A@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
In-Reply-To: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

To workaround the problem, you can append __attribute__((weak)) to the decl=
aration of those discarded symbols defined in section ".exit.text".

Another workaround is to keep section ".exit.text" by modifying arch/ia64/v=
mlinux.lds.S.=20

The device driver author might be able to answer why it is written that way.

Thanks,
Pingping (Benjamin) Liu
Intel China Software Center


>-----Original Message-----
>From: linux-ia64-owner@vger.kernel.org=20
>[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Sourav Sen
>Sent: 2004=C4=EA3=D4=C211=C8=D5 14:53
>To: linux-ia64@vger.kernel.org
>Subject: 2.6.3 compilation problem
>
>
>Hi,
>
>While compiling Linux 2.6.3 + ia64 patch for it, using
>the following:
>
>[sourav]$ gcc --version
>gcc (GCC) 3.1
>[sourav]$ as --version
>GNU assembler 2.13.90 20030125
>[sourav]$ ld --version
>GNU ld version 2.12.90 20020604
>
>I get the following error while doing
>make vmlinux
>
>------
>[...]
> IKCFG   kernel/config_data.h
>  CC      kernel/configs.o
>  LD      kernel/built-in.o
>  GEN     .version
>  CHK     include/linux/compile.h
>dnsdomainname: Host name lookup failure
>  UPD     include/linux/compile.h
>  CC      init/version.o
>  LD      init/built-in.o
>  LD      .tmp_vmlinux1
>drivers/built-in.o: In function `serio_close':
>drivers/built-in.o(.text+0x130c02): undefined reference to=20
>`local symbols in
>discarded section .exit.text'
>drivers/built-in.o: In function `serio_init':
>drivers/built-in.o(.init.text+0x10502): undefined reference to `local
>symbols in discarded section .exit.text'
>make: *** [.tmp_vmlinux1] Error 1
>[...]
>--------
>
>Any idea what I am doing wrong?
>
>TIA
>--Sourav
>
>-
>To unsubscribe from this list: send the line "unsubscribe=20
>linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
