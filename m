From: Baoquan He <bhe@redhat.com>
Date: Mon, 18 Apr 2016 05:32:53 +0000
Subject: Re: [PATCH 1/3] kexec: don't invoke OOM-killer for control page allocation
Message-Id: <20160418053253.GA3602@x1.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160414195938.GV19428@n2100.arm.linux.org.uk>
 <E1aqnQo-0001Tu-Ch@rmk-PC.arm.linux.org.uk>
In-Reply-To: <E1aqnQo-0001Tu-Ch@rmk-PC.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, kexec@lists.infradead.org

On 04/14/16 at 09:00pm, Russell King wrote:
> If we are unable to find a suitable page when allocating the control
> page, do not invoke the OOM-killer: killing processes probably isn't
> going to help.

Originally kexec was made to reboot to test kernel quickly. If 1st
kernel is palyed and hurted in a bad state and developer want to discard
it and take a quick reboot, why don't we have a best try to make a
successful kexec load?

I personally think this change sounds un-reasonable.

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
> -- 
> 2.1.0
> 
> 
> _______________________________________________
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec
