From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Thu, 11 Mar 2004 06:57:09 +0000
Subject: RE: 2.6.3 compilation problem
Message-Id: <3AA03342E913FA4BA6D8BD0732BFC74B0515519B@pdsmsx402.pd.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
In-Reply-To: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Did you enable CONFIG_HOTPLUG in your .config file?

Enable it and compile it again.

Yanmin

>-----Original Message-----
>From: linux-ia64-owner@vger.kernel.org [mailto:linux-ia64-
>owner@vger.kernel.org] On Behalf Of Sourav Sen
>Sent: 2004年3月11日 14:53
>To: linux-ia64@vger.kernel.org
>Subject: 2.6.3 compilation problem
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
>drivers/built-in.o(.text+0x130c02): undefined reference to `local symbols
>in
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
>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
