From: Pratyush Anand <panand@redhat.com>
Date: Fri, 29 Apr 2016 14:57:24 +0000
Subject: Re: [PATCH 08/12] kexec: don't invoke OOM-killer for control page allocation
Message-Id: <CAHB_Gupx7QgRdAaFuNSTdP6ZErSPRiaFcVYfeFXGbmqezAvSAA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
	<E1aviFE-0000jS-UI@rmk-PC.arm.linux.org.uk>
In-Reply-To: <E1aviFE-0000jS-UI@rmk-PC.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, Jonathan Corbet <corbet@lwn.net>, Ian Campbell <ijc+devicetree@hellion.org.uk>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, Vivek Goyal <vgoyal@redhat.com>

On Thu, Apr 28, 2016 at 2:58 PM, Russell King
<rmk+kernel@arm.linux.org.uk> wrote:
> If we are unable to find a suitable page when allocating the control
> page, do not invoke the OOM-killer: killing processes probably isn't
> going to help.
>
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
>  include/linux/kexec.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/linux/kexec.h b/include/linux/kexec.h
> index 2cc643c6e870..1b32ab587f66 100644
> --- a/include/linux/kexec.h
> +++ b/include/linux/kexec.h
> @@ -41,7 +41,7 @@
>  #endif
>
>  #ifndef KEXEC_CONTROL_MEMORY_GFP
> -#define KEXEC_CONTROL_MEMORY_GFP GFP_KERNEL
> +#define KEXEC_CONTROL_MEMORY_GFP (GFP_KERNEL | __GFP_NORETRY)
>  #endif
>
>  #ifndef KEXEC_CONTROL_PAGE_SIZE

Reviewed-by: Pratyush Anand <panand@redhat.com>
