From: Laszlo Ersek <lersek@redhat.com>
Date: Wed, 03 Sep 2014 13:24:49 +0000
Subject: Re: [PATCH v2 0/5] beautify EFI memmap logs
Message-Id: <540716A1.7040905@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409743943-16934-1-git-send-email-lersek@redhat.com> <CAKv+Gu_Yk-q0gf+EHc3EYQ=obLT2nj6Kj6qPTk678ASFEW+ZFQ@mail.gmail.com>
In-Reply-To: <CAKv+Gu_Yk-q0gf+EHc3EYQ=obLT2nj6Kj6qPTk678ASFEW+ZFQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Ingo Molnar <mingo@kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "x86@kernel.org" <x86@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Matt Fleming <matt.fleming@intel.com>, Mark Salter <msalter@redhat.com>

On 09/03/14 15:01, Ard Biesheuvel wrote:
> On 3 September 2014 13:32, Laszlo Ersek <lersek@redhat.com> wrote:
>> changes in v2:
>> - explain with examples how the log's appearance changes, in patches 3-5
>>   [Ingo]
>>
>> v1 blurb:
>>
>>> It's a pain to analyze EFI memmap logs while debugging, especially to
>>> verify the memory types (an enum) and the memory attributes (a
>>> bitmap). This series renders those columns human-readable, and unifies
>>> their formatting between x86, ia64 and arm64.
>>
> 
> Tested-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> (on arm64 only)
> 
> +1 for aligning between architectures
> +1 for cleaning up the output to make it more readable
> 
> The only thing I am not entirely convinced about is printing all those
> memory attributes: is it really so interesting to know that region X
> /can/ be configured as writeback, write through, write combining etc
> etc, as most regions seem to support most attributes, yet it tells you
> nothing about what the kernel ends up doing with that information. In
> the arm64 case, for instance, all MEMORY_WB ranges are mapped
> writeback cached, and everything else is mapped uncached.

You don't need these attributes spelled out when you're not debugging.
In that case, either build without CONFIG_EFI_DEBUG (on x86 and ia64),
or don't pass uefi_debug=1 (on arm64).

When you're debugging however, you need every bit of info you can get.
For example, assume a tricky bug in exactly that part of the arm64 code
that you just described above. You'll be flip-flopping between the
kernel source and the original, pristine memory map dump. It's much
easier to ignore a few words / columns in the log (even: cut it out with
a script or interactively) than to read bitmaps in hex (or to decode
them in a script). I know because I grew to hate these hex-encoded
attributes and dec-encoded enum constants when I was developing S3 for
OVMF, and fighting the memmap.

A good analogue is ACPI debugging in the kernel. The ACPI subsystem
comes with a very elaborate heap of switches, facility bitmaps, log
levels, and so on. The end result is that it is faster to add printks to
your suspect location(s) in ACPI, rebuild, retest, repeat, than to learn
to use the acpi debug flags. (And I did the former when I was recently
fixing a bug in the RHEL-6 kernel, in the intersection of ACPI and EFI.)

So yes, I think that this detailed format is preferable.

Thanks,
Laszlo

