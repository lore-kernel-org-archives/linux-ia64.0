From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 27 Aug 2003 16:22:32 +0000
Subject: RE: kernel update (relative to 2.6.0-test4)
Message-Id: <marc-linux-ia64-106200160512868@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106192276030286@msgid-missing>
In-Reply-To: <marc-linux-ia64-106192276030286@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 27 Aug 2003 09:01:54 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  >> The latest ia64 patch is now available at
  >> ftp://www.kernel.org/pub/linux/kernel/ports/ia64/v2.5/ in
  >> file:
  >> 
  >> linux-2.6.0-test4-ia64-030826.diff.gz
  >> 

  Tony> Last few lines of the build output (building for Tiger):

  Tony> KSYM    .tmp_kallsyms2.S
  Tony> AS      .tmp_kallsyms2.o
  Tony> LD      vmlinux
  Tony> OBJCOPY arch/ia64/hp/sim/boot/vmlinux.bin
  Tony> BFD: arch/ia64/hp/sim/boot/vmlinux.bin: warning: allocated section `.data.nosave' not in segment
  Tony> GZIP    arch/ia64/hp/sim/boot/vmlinux.gz
  Tony> LN      vmlinux.gz
  Tony> Kernel: vmlinux.gz is ready

  Tony> Is that .../hp/sim/boot/... path right?

Not really, but it doesn't hurt, AFAIK (I'll try to remember to clean
it up, though).

  Tony> Any clues on what the warning from OBJCOPY really means?

Nope.  I don't get that (building for zx1):

  KSYM    .tmp_kallsyms2.S
  AS      .tmp_kallsyms2.o
  LD      vmlinux
  Building modules, stage 2.
  OBJCOPY arch/ia64/hp/sim/boot/vmlinux.bin
  GZIP    arch/ia64/hp/sim/boot/vmlinux.gz
  MODPOST
  LN      vmlinux.gz
  Kernel: vmlinux.gz is ready

	--david
