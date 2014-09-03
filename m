From: Matt Fleming <matt@console-pimps.org>
Date: Wed, 03 Sep 2014 13:18:18 +0000
Subject: Re: [PATCH v2 0/5] beautify EFI memmap logs
Message-Id: <20140903131818.GE3001@console-pimps.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409743943-16934-1-git-send-email-lersek@redhat.com>
 <CAKv+Gu_Yk-q0gf+EHc3EYQ=obLT2nj6Kj6qPTk678ASFEW+ZFQ@mail.gmail.com>
In-Reply-To: <CAKv+Gu_Yk-q0gf+EHc3EYQ=obLT2nj6Kj6qPTk678ASFEW+ZFQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Laszlo Ersek <lersek@redhat.com>, Ingo Molnar <mingo@kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "x86@kernel.org" <x86@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Matt Fleming <matt.fleming@intel.com>, Mark Salter <msalter@redhat.com>

On Wed, 03 Sep, at 03:01:31PM, Ard Biesheuvel wrote:
> 
> Tested-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> (on arm64 only)
> 
> +1 for aligning between architectures
> +1 for cleaning up the output to make it more readable
 
Thanks Ard.

> The only thing I am not entirely convinced about is printing all those
> memory attributes: is it really so interesting to know that region X
> /can/ be configured as writeback, write through, write combining etc
> etc, as most regions seem to support most attributes, yet it tells you
> nothing about what the kernel ends up doing with that information. In
> the arm64 case, for instance, all MEMORY_WB ranges are mapped
> writeback cached, and everything else is mapped uncached.

Personally, I think it's good to get an unadulterated version of the
firmware memory map (for vicarious debugging) before the kernel has a
chance to mess with it.

-- 
Matt Fleming, Intel Open Source Technology Center
