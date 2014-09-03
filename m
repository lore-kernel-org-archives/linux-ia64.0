From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 03 Sep 2014 13:01:31 +0000
Subject: Re: [PATCH v2 0/5] beautify EFI memmap logs
Message-Id: <CAKv+Gu_Yk-q0gf+EHc3EYQ=obLT2nj6Kj6qPTk678ASFEW+ZFQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409743943-16934-1-git-send-email-lersek@redhat.com>
In-Reply-To: <1409743943-16934-1-git-send-email-lersek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Laszlo Ersek <lersek@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "x86@kernel.org" <x86@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Matt Fleming <matt.fleming@intel.com>, Mark Salter <msalter@redhat.com>

On 3 September 2014 13:32, Laszlo Ersek <lersek@redhat.com> wrote:
> changes in v2:
> - explain with examples how the log's appearance changes, in patches 3-5
>   [Ingo]
>
> v1 blurb:
>
>> It's a pain to analyze EFI memmap logs while debugging, especially to
>> verify the memory types (an enum) and the memory attributes (a
>> bitmap). This series renders those columns human-readable, and unifies
>> their formatting between x86, ia64 and arm64.
>

Tested-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
(on arm64 only)

+1 for aligning between architectures
+1 for cleaning up the output to make it more readable

The only thing I am not entirely convinced about is printing all those
memory attributes: is it really so interesting to know that region X
/can/ be configured as writeback, write through, write combining etc
etc, as most regions seem to support most attributes, yet it tells you
nothing about what the kernel ends up doing with that information. In
the arm64 case, for instance, all MEMORY_WB ranges are mapped
writeback cached, and everything else is mapped uncached.

-- 
Ard.


> Laszlo Ersek (5):
>   efi: add macro for EFI_MEMORY_UCE memory attribute
>   efi: introduce efi_md_typeattr_format()
>   x86: efi: format EFI memory type & attrs with efi_md_typeattr_format()
>   ia64: efi: format EFI memory type & attrs with
>     efi_md_typeattr_format()
>   arm64: efi: format EFI memory type & attrs with
>     efi_md_typeattr_format()
>
>  include/linux/efi.h         |  8 +++++++
>  arch/arm64/kernel/efi.c     | 26 +++++----------------
>  arch/ia64/kernel/efi.c      |  6 +++--
>  arch/x86/platform/efi/efi.c |  7 ++++--
>  drivers/firmware/efi/efi.c  | 57 +++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 80 insertions(+), 24 deletions(-)
>
> --
> 1.8.3.1
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
