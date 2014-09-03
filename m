From: Matt Fleming <matt@console-pimps.org>
Date: Wed, 03 Sep 2014 12:07:51 +0000
Subject: Re: [PATCH 3/5] x86: efi: format EFI memory type & attrs with efi_md_typeattr_format()
Message-Id: <20140903120751.GC3001@console-pimps.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409532820-5027-1-git-send-email-lersek@redhat.com>
 <1409532820-5027-4-git-send-email-lersek@redhat.com>
In-Reply-To: <1409532820-5027-4-git-send-email-lersek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Laszlo Ersek <lersek@redhat.com>
Cc: linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, msalter@redhat.com

On Mon, 01 Sep, at 02:53:38AM, Laszlo Ersek wrote:
> Signed-off-by: Laszlo Ersek <lersek@redhat.com>
> ---
>  arch/x86/platform/efi/efi.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)

I know this is a straight forward patch in the context of this series,
but you need to include a rationale, so that we know in 6 months, 12
months and 5 years from now why this change made sense.

Something like,

  "Reduce the amount of duplicated code by using the helper function"

would be fine.

-- 
Matt Fleming, Intel Open Source Technology Center
