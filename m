From: Matt Fleming <matt@console-pimps.org>
Date: Mon, 07 Jul 2014 14:50:16 +0000
Subject: Re: [PATCH v7 01/10] arch/ia64: Define early_memunmap()
Message-Id: <20140707145016.GB2914@console-pimps.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1404150784-27921-1-git-send-email-daniel.kiper@oracle.com>
 <1404150784-27921-2-git-send-email-daniel.kiper@oracle.com>
In-Reply-To: <1404150784-27921-2-git-send-email-daniel.kiper@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>
Cc: linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org, andrew.cooper3@citrix.com, boris.ostrovsky@oracle.com, david.vrabel@citrix.com, eshelton@pobox.com, fenghua.yu@intel.com, hpa@zytor.com, ian.campbell@citrix.com, jbeulich@suse.com, jeremy@goop.org, konrad.wilk@oracle.com, matt.fleming@intel.com, mingo@redhat.com, mjg59@srcf.ucam.org, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, Daniel Kiper <daniel.kiper@oracle.com>, tony.luck@intel.com

On Mon, 30 Jun, at 07:52:55PM, Daniel Kiper wrote:
> This is odd to use early_iounmap() function do tear down mapping
> created by early_memremap() function, even if it works right now,
> because they belong to different set of functions. The former is
> I/O related function and the later is memory related. So, create
> early_memunmap() macro which in real is early_iounmap(). This
> thing will help to not confuse code readers longer by mixing
> functions from different classes.
> 
> EFI patches following this patch uses that functionality.
> 
> Signed-off-by: Daniel Kiper <daniel.kiper@oracle.com>
> ---
>  arch/ia64/include/asm/io.h |    1 +
>  1 file changed, 1 insertion(+)

Tony, this looks pretty straight forward but I'd be much obliged if you
could give me an Acked-by.

-- 
Matt Fleming, Intel Open Source Technology Center
