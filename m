From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 27 Aug 2003 16:01:54 +0000
Subject: RE: kernel update (relative to 2.6.0-test4)
Message-Id: <marc-linux-ia64-106200079911474@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106192276030286@msgid-missing>
In-Reply-To: <marc-linux-ia64-106192276030286@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The latest ia64 patch is now available at
> ftp://www.kernel.org/pub/linux/kernel/ports/ia64/v2.5/ in
> file:
> 
>  linux-2.6.0-test4-ia64-030826.diff.gz
> 

Last few lines of the build output (building for Tiger):

  KSYM    .tmp_kallsyms2.S
  AS      .tmp_kallsyms2.o
  LD      vmlinux
  OBJCOPY arch/ia64/hp/sim/boot/vmlinux.bin
BFD: arch/ia64/hp/sim/boot/vmlinux.bin: warning: allocated section `.data.nosave' not in segment
  GZIP    arch/ia64/hp/sim/boot/vmlinux.gz
  LN      vmlinux.gz
  Kernel: vmlinux.gz is ready

Is that .../hp/sim/boot/... path right?  I don't have CONFIG_IA64_HP_SIM
set in my .config.

Any clues on what the warning from OBJCOPY really means?

-Tony
