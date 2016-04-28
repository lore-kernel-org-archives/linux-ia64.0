From: Baoquan He <bhe@redhat.com>
Date: Thu, 28 Apr 2016 09:56:24 +0000
Subject: Re: [PATCH 2/3] kexec: ensure user memory sizes do not wrap
Message-Id: <20160428095624.GB10691@x1.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160414195938.GV19428@n2100.arm.linux.org.uk>
 <E1aqnQt-0001U2-Oa@rmk-PC.arm.linux.org.uk>
In-Reply-To: <E1aqnQt-0001U2-Oa@rmk-PC.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, kexec@lists.infradead.org

On 04/14/16 at 09:00pm, Russell King wrote:
> Ensure that user memory sizes do not wrap around when validating the
> user input, which can lead to the following input validation working
> incorrectly.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
>  kernel/kexec_core.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> index 8d34308ea449..d719a4d0ef55 100644
> --- a/kernel/kexec_core.c
> +++ b/kernel/kexec_core.c
> @@ -169,6 +169,8 @@ int sanity_check_segment_list(struct kimage *image)
>  
>  		mstart = image->segment[i].mem;
>  		mend   = mstart + image->segment[i].memsz;
> +		if (mstart > mend)
> +			return result;

Though this checking has been done in kexec utitlity, I am fine it's
re-check in kernel space. Anyway it keeps code safer. Ack it.

Acked-by: Baoquan He <bhe@redhat.com>


>  		if ((mstart & ~PAGE_MASK) || (mend & ~PAGE_MASK))
>  			return result;
>  		if (mend >= KEXEC_DESTINATION_MEMORY_LIMIT)
> -- 
> 2.1.0
> 
> 
> _______________________________________________
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec
