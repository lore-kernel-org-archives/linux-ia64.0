From: Jakub Jelinek <jakub@redhat.com>
Date: Thu, 14 Oct 2004 08:50:05 +0000
Subject: Re: [PATCH] Support ia32 exec domains without CONFIG_IA32_SUPPORT
Message-Id: <20041014085003.GM31909@devserv.devel.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41643EC0.1010505@intel.com> <20041007142710.A12688@infradead.org> <4165D4C9.2040804@intel.com> <mailman.1097223239.25078@unix-os.sc.intel.com> <41671696.1060706@intel.com> <mailman.1097403036.11924@unix-os.sc.intel.com> <416AF599.2060801@intel.com> <1097617824.5178.20.camel@localhost.localdomain> <416C5ECF.6060402@intel.com>
In-Reply-To: <416C5ECF.6060402@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arun Sharma <arun.sharma@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, Oct 12, 2004 at 03:46:39PM -0700, Arun Sharma wrote:
> --- linux-2.6-cvs/fs/namei.c	2 Oct 2004 17:59:55 -0000	1.110
> +++ linux-2.6-cvs/fs/namei.c	8 Oct 2004 18:14:11 -0000
> @@ -897,7 +897,7 @@
>  	return 1;
>  }
>  
> -void set_fs_altroot(void)
> +int set_fs_altroot(const char __user *altroot)
>  {
>  	char *emul = __emul_prefix();

I think you should change this to char *emul;

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
> +

and add here
	else
		emul = __emul_prefix();

There is no point in calling __emul_prefix () when it will be thrown away.

	Jakub
