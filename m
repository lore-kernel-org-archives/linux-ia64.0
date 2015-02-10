From: Paolo Bonzini <pbonzini@redhat.com>
Date: Tue, 10 Feb 2015 08:02:36 +0000
Subject: Re: [PATCH] KVM: ia64: drop kvm.h from installed user headers
Message-Id: <54D9BB1C.4000807@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1423509887-4822-1-git-send-email-vapier@gentoo.org>
In-Reply-To: <1423509887-4822-1-git-send-email-vapier@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On 09/02/2015 20:24, Mike Frysinger wrote:
> The header was deleted, so stop trying to install it.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  arch/ia64/include/uapi/asm/Kbuild | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/arch/ia64/include/uapi/asm/Kbuild b/arch/ia64/include/uapi/asm/Kbuild
> index 1b3f5eb..891002b 100644
> --- a/arch/ia64/include/uapi/asm/Kbuild
> +++ b/arch/ia64/include/uapi/asm/Kbuild
> @@ -18,7 +18,6 @@ header-y += intrinsics.h
>  header-y += ioctl.h
>  header-y += ioctls.h
>  header-y += ipcbuf.h
> -header-y += kvm.h
>  header-y += kvm_para.h
>  header-y += mman.h
>  header-y += msgbuf.h
> 

Applied, thanks!

Paolo
