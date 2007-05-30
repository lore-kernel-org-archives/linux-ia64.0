From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 30 May 2007 22:39:15 +0000
Subject: RE: BUG: sleeping function called from invalid context at
Message-Id: <Pine.LNX.4.64.0705301537450.1529@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A019298C6@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A019298C6@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, 30 May 2007, Luck, Tony wrote:

> > WARNING: init/built-in.o - Section mismatch: reference to .init.data: from .sdata after 'root_mountflags' (at offset 0x38)
> 
> I thought that I'd got the section mis-match warnings down to
> just one (and that was in ACPI code, so I sent a patch to Len
> for it).

Hmmm... My compilation of 2.6.21-rc2-mm1 just aborted with:
(used sn2_defconfig).

 LD      .tmp_vmlinux1
`.exit.text' referenced in section `.init.text' of drivers/built-in.o: 
defined in discarded section `.exit.text' of drivers/built-in.o
make[2]: *** [.tmp_vmlinux1] Error 1
make[1]: *** [targz-pkg] Error 2
make: *** [targz-pkg] Error 2

