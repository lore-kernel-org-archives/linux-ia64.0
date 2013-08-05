From: Matt Fleming <matt@console-pimps.org>
Date: Mon, 05 Aug 2013 12:26:28 +0000
Subject: Re: [PATCH v2 5/5] efi: x86: make efi_lookup_mapped_addr() a common function
Message-Id: <20130805122628.GS2515@console-pimps.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1375462582-16423-1-git-send-email-leif.lindholm@linaro.org>
 <1375462582-16423-6-git-send-email-leif.lindholm@linaro.org>
In-Reply-To: <1375462582-16423-6-git-send-email-leif.lindholm@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leif Lindholm <leif.lindholm@linaro.org>
Cc: linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, tony.luck@gmail.com, patches@linaro.org

On Fri, 02 Aug, at 05:56:22PM, Leif Lindholm wrote:
> efi_lookup_mapped_addr() is a handy utility for other platforms than
> x86. Move it from arch/x86 to drivers/firmware. Add memmap pointer
> to global efi structure, and initialise it on x86.
> 
> Signed-off-by: Leif Lindholm <leif.lindholm@linaro.org>
> ---
>  arch/x86/platform/efi/efi.c |   30 ++----------------------------
>  drivers/firmware/efi/efi.c  |   32 ++++++++++++++++++++++++++++++++
>  include/linux/efi.h         |    1 +
>  3 files changed, 35 insertions(+), 28 deletions(-)

Looks good.

Tony, shout if you have any objection to modifying 'struct efi'.

-- 
Matt Fleming, Intel Open Source Technology Center
