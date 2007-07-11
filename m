From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 11 Jul 2007 20:34:05 +0000
Subject: RE: [IA64] [kdump] machveg=dig on hpzx1 platforms
Message-Id: <617E1C2C70743745A92448908E030B2A01E6CC56@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <467AE260.7030906@hp.com>
References: <20070621182441.GA21840@suse.de>
In-Reply-To: <20070621182441.GA21840@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Terry Loftin <terry.loftin@hp.com>, Bernhard Walle <bwalle@suse.de>
Cc: Prarit Bhargava <prarit@redhat.com>, linux-ia64@vger.kernel.org, Khalid Aziz <khalid_aziz@hp.com>, kexec@lists.infradead.org

> Here is a patch to do that.  We use this internally, but
> I had forgotten to post it.

Terry,

Just got to applying some older patches ... perhaps this one has
been sitting too long because I had some apply & build problems with it.

Building with arch/ia64/configs/zx1_defconfig and with this patch
hand applied I get:

  LD      .tmp_vmlinux1
arch/ia64/hp/common/built-in.o(.init.text+0xcc2): In function `sba_init':
: undefined reference to `swiotlb_late_init_with_default_size'
arch/ia64/hp/common/built-in.o(.init.text+0xd02): In function `sba_init':
: undefined reference to `machvec_init'
make: *** [.tmp_vmlinux1] Error 1

sba_init() uses these routines inside #ifdef CONFIG_I64_GENERIC, perhaps
you need to do the same?


Other issues:
1) No "Signed-off-by"

2) +#include <linux/crash_dump.h>

We usually group all the <linux/*> includes together before the <asm/*> ones

3) +extern int swiotlb_late_init_with_default_size (size_t size);

extern declarations in ".c" files are frowned upon.  This should be in
a header file, which should be included (though I see that this guideline
has already been ignored as you were just moving the declaration).

-Tony
