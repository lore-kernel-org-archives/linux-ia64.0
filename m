From: Paolo Bonzini <pbonzini@redhat.com>
Date: Thu, 20 Nov 2014 13:49:41 +0000
Subject: Re: [PATCH] KVM: ia64: remove
Message-Id: <546DF175.7040009@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416431143-31843-1-git-send-email-pbonzini@redhat.com> <20141120133809.GA30792@potion.brq.redhat.com>
In-Reply-To: <20141120133809.GA30792@potion.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>



On 20/11/2014 14:38, Radim Krčmář wrote:
> I propose another removal.
> (The reasoning below wasn't confirmed with ia64 compiler.
> I'd remove the ioctls even if they worked.)

Checked and applied, thanks.

Paolo

> ---8<---
> KVM: remove buggy ia64 specific ioctls
> 
> IA64 is no longer present so new applications shouldn't use them.
> 
> The main problem is that they most likely didn't work even before,
> because we have misused ioctl
> 
>   #define KVM_SET_GUEST_DEBUG       _IOW(KVMIO,  0x9b, struct kvm_guest_debug)
>   #define KVM_IA64_VCPU_SET_STACK   _IOW(KVMIO,  0x9b, void *)
> 
> as
> 
>   struct kvm_guest_debug {
>   	__u32 control;
>   	__u32 pad;
>   	struct kvm_guest_debug_arch arch;
>   };
> 
> and
> 
>   struct kvm_guest_debug_arch {
>   };
> 
> mean that
> 
>   sizeof(struct kvm_guest_debug) = sizeof(void *) = 8
> 
> thus
> 
>   KVM_SET_GUEST_DEBUG = KVM_IA64_VCPU_SET_STACK
> 
> and KVM_SET_GUEST_DEBUG is handled before KVM_IA64_VCPU_SET_STACK.
> 
> Signed-off-by: Radim Krčmář <rkrcmar@redhat.com>
> ---
>  include/uapi/linux/kvm.h | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/include/uapi/linux/kvm.h b/include/uapi/linux/kvm.h
> index 6d59e5b..a37fd12 100644
> --- a/include/uapi/linux/kvm.h
> +++ b/include/uapi/linux/kvm.h
> @@ -1099,9 +1099,6 @@ struct kvm_s390_ucas_mapping {
>  #define KVM_X86_SETUP_MCE         _IOW(KVMIO,  0x9c, __u64)
>  #define KVM_X86_GET_MCE_CAP_SUPPORTED _IOR(KVMIO,  0x9d, __u64)
>  #define KVM_X86_SET_MCE           _IOW(KVMIO,  0x9e, struct kvm_x86_mce)
> -/* IA64 stack access */
> -#define KVM_IA64_VCPU_GET_STACK   _IOR(KVMIO,  0x9a, void *)
> -#define KVM_IA64_VCPU_SET_STACK   _IOW(KVMIO,  0x9b, void *)
>  /* Available with KVM_CAP_VCPU_EVENTS */
>  #define KVM_GET_VCPU_EVENTS       _IOR(KVMIO,  0x9f, struct kvm_vcpu_events)
>  #define KVM_SET_VCPU_EVENTS       _IOW(KVMIO,  0xa0, struct kvm_vcpu_events)
> 
