From: Christoph Hellwig <hch@infradead.org>
Date: Sun, 10 Oct 2004 10:10:47 +0000
Subject: Re: [PATCH] Support ia32 exec domains without CONFIG_IA32_SUPPORT
Message-Id: <20041010101047.GA28456@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <41643EC0.1010505@intel.com>
In-Reply-To: <41643EC0.1010505@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 08, 2004 at 03:37:10PM -0700, Arun Sharma wrote:
> On 10/8/2004 1:08 AM, David Mosberger wrote:
> 
> >Unfortunately, that thread ran out in a rather unhelpful manner, as
> >far as I can see.  Rusty seemed to agree that the performance-hit of
> >doing it all in user-level was unacceptably high, but I didn't see any
> >actual numbers.  There was a suggestion to decouple the altroot from
> >the personality which makes some sense, but nobody actually did
> >anything about it?
> >
> 
> I'd really like this issue to be resolved one way or the other. I'm not 
> sure I've heard a convincing argument on why my original patch(which adds a 
> new exec domain unconditionally) should not be applied.
> 
> I'm fine with the attached patch to set the altroot via a system call as 
> well.

I'd still like to see some number on how much smaller a userland emulation
is.  Best using qumu because that's opensource and we simply don't care
about intel's propritary stuff.  Else your patch looks pretty okay - but
I'd need to go through linux-kernel and hooking up to all architectures.

> -void set_fs_altroot(void)
> +int set_fs_altroot(const char __user *altroot)
>  {
>  	char *emul = __emul_prefix();
>  	
>  	struct nameidata nd;
> @@ -905,12 +905,20 @@
>  	struct dentry *dentry = NULL, *olddentry;
>  	int err;
>  
> +	if (altroot) {
> +		emul = getname(altroot);
> +		if (IS_ERR(emul))
> +			return PTR_ERR(emul);
> +	}

the interface here is pretty awkward.  I'd say rename this function to
__set_fs_altroot and always pass altroot as a kernel string here, do the
getname in sys_altroot and the __emul_prefix() in set_fs_altroot which will
be a one-liner wrapper.

