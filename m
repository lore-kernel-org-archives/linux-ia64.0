From: Matthias Kaehlcke <mka@chromium.org>
Date: Wed, 12 Apr 2017 01:38:34 +0000
Subject: Re: [PATCH] kbuild: Consolidate header generation from ASM offset information
Message-Id: <20170412013834.GE28657@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170403193739.84905-1-mka@chromium.org>
 <CAK7LNAQ0sUnXJAzEy8ukK994mUMPJQKHAvyqpvqOXUfaX-pSvA@mail.gmail.com>
In-Reply-To: <CAK7LNAQ0sUnXJAzEy8ukK994mUMPJQKHAvyqpvqOXUfaX-pSvA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Marek <mmarek@suse.com>, Jan Kiszka <jan.kiszka@siemens.com>, Kieran Bingham <kieran.bingham@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Grant Grundler <grundler@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>

Hi Masahiro,

El Wed, Apr 12, 2017 at 09:03:28AM +0900 Masahiro Yamada ha dit:

> 2017-04-04 4:37 GMT+09:00 Matthias Kaehlcke <mka@chromium.org>:
> > Largely redundant code is used in different places to generate C headers
> > from offset information extracted from assembly language output.
> > Consolidate the code in a Makefile include and use this instead.
> >
> > Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
> 
> 
> Please move sed-y and filechk_offsets to scripts/Makefile.lib .
> (You may need to rename sed-y
> because arch/xtensa/kernel/Makefile uses this name.)
> 
> 
> We see various helpers in scripts/Makefile.lib,
> so I do not think we need to create a new file just for this one.
> 
> Then, please reuse it from arch/ia64/kernel/Makefile and scripts/mod/Makefile.
> Like this:
> 
> include/generated/nr-irqs.h: arch/$(SRCARCH)/kernel/nr-irqs.s FORCE
>         $(call filechk,offsets,__ASM_NR_IRQS_H__)
> 
> $(obj)/$(devicetable-offsets-file): $(obj)/devicetable-offsets.s FORCE
>         $(call filechk,offsets,__DEVICETABLE_OFFSETS_H__)

Thanks for your comments, I'll rework the patch accordingly.

Cheers

Matthias
