From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 31 May 2007 20:04:46 +0000
Subject: Re: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <20070531200446.GA27305@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01929DD3@scsmsx411.amr.corp.intel.com> <Pine.LNX.4.64.0705302019040.5583@schroedinger.engr.sgi.com> <465EE7BB.4050605@redhat.com>
In-Reply-To: <465EE7BB.4050605@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Prarit Bhargava <prarit@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, sam@ravnborg.org

On Thu, May 31, 2007 at 11:20:27AM -0400, Prarit Bhargava wrote:
> 
> Something is borken in modpost because I found a bug in the loopback 
> code which is a _REAL_ bug.

Here is the result for an i386 allmodconfig build:
WARNING: arch/i386/kernel/built-in.o(.init.text+0x3966): Section mismatch: reference to .exit.text: (between 'microcode_init' and 'parse_maxcpus')
WARNING: arch/i386/kernel/built-in.o(.init.text+0x3992): Section mismatch: reference to .exit.text: (between 'microcode_init' and 'parse_maxcpus')
  Building modules, stage 2.
Kernel: arch/i386/boot/bzImage is ready  (#4)
  MODPOST 2100 modules
WARNING: drivers/acpi/asus_acpi.o(.init.text+0xb7): Section mismatch: reference to .exit.text: (after 'init_module')
WARNING: drivers/acpi/toshiba_acpi.o(.init.text+0x13a): Section mismatch: reference to .exit.text: (after 'init_module')
WARNING: drivers/block/loop.o(.init.text+0x6b): Section mismatch: reference to .exit.text: (after 'init_module')
WARNING: drivers/isdn/hardware/eicon/divadidd.o(.init.text+0xc4): Section mismatch: reference to .exit.text: (between 'init_module' and 'diddfunc_init')
WARNING: drivers/isdn/hardware/eicon/divas.o(.init.text+0xf4): Section mismatch: reference to .exit.text:divasfunc_exit (between 'init_module' and 'divasfunc_init')
WARNING: drivers/isdn/hardware/eicon/divas.o(.init.text+0x10d): Section mismatch: reference to .exit.text:divasfunc_exit (between 'init_module' and 'divasfunc_init')
WARNING: drivers/isdn/hardware/eicon/divas.o(.init.text+0x148): Section mismatch: reference to .exit.text:divasfunc_exit (between 'init_module' and 'divasfunc_init')
WARNING: drivers/kvm/kvm-intel.o(.init.text+0xbd): Section mismatch: reference to .exit.text: (between 'hardware_setup' and 'vmx_disabled_by_bios')
WARNING: drivers/net/hp100.o(.init.text+0x26a): Section mismatch: reference to .exit.text: (after 'init_module')

	Sam
