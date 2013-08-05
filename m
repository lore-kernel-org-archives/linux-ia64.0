From: Matt Fleming <matt@console-pimps.org>
Date: Mon, 05 Aug 2013 12:18:56 +0000
Subject: Re: [PATCH v2 4/5] efi: ia64: use common code for (U)EFI configuration scanning
Message-Id: <20130805121856.GR2515@console-pimps.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1375462582-16423-1-git-send-email-leif.lindholm@linaro.org>
 <1375462582-16423-5-git-send-email-leif.lindholm@linaro.org>
In-Reply-To: <1375462582-16423-5-git-send-email-leif.lindholm@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leif Lindholm <leif.lindholm@linaro.org>
Cc: linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, tony.luck@gmail.com, patches@linaro.org

On Fri, 02 Aug, at 05:56:21PM, Leif Lindholm wrote:
> This patch makes ia64 use the new common code for configuration table
> scanning. It also removes the local definition of the global "efi"
> data structure.
> 
> Signed-off-by: Leif Lindholm <leif.lindholm@linaro.org>
> ---
>  arch/ia64/kernel/efi.c |   54 ++++++++++--------------------------------------
>  1 file changed, 11 insertions(+), 43 deletions(-)

Tony, Ack?

-- 
Matt Fleming, Intel Open Source Technology Center
