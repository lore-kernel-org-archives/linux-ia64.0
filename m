From: "Sourav Sen" <souravs@india.hp.com>
Date: Thu, 11 Mar 2004 06:55:06 +0000
Subject: 2.6.3 compilation problem
Message-Id: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

While compiling Linux 2.6.3 + ia64 patch for it, using
the following:

[sourav]$ gcc --version
gcc (GCC) 3.1
[sourav]$ as --version
GNU assembler 2.13.90 20030125
[sourav]$ ld --version
GNU ld version 2.12.90 20020604

I get the following error while doing
make vmlinux

------
[...]
 IKCFG   kernel/config_data.h
  CC      kernel/configs.o
  LD      kernel/built-in.o
  GEN     .version
  CHK     include/linux/compile.h
dnsdomainname: Host name lookup failure
  UPD     include/linux/compile.h
  CC      init/version.o
  LD      init/built-in.o
  LD      .tmp_vmlinux1
drivers/built-in.o: In function `serio_close':
drivers/built-in.o(.text+0x130c02): undefined reference to `local symbols in
discarded section .exit.text'
drivers/built-in.o: In function `serio_init':
drivers/built-in.o(.init.text+0x10502): undefined reference to `local
symbols in discarded section .exit.text'
make: *** [.tmp_vmlinux1] Error 1
[...]
--------

Any idea what I am doing wrong?

TIA
--Sourav

