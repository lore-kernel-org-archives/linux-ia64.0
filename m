From: Matt Fleming <matt@console-pimps.org>
Date: Wed, 03 Sep 2014 12:46:13 +0000
Subject: Re: [PATCH 2/5] efi: introduce efi_md_typeattr_format()
Message-Id: <20140903124613.GD3001@console-pimps.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409532820-5027-1-git-send-email-lersek@redhat.com>
 <1409532820-5027-3-git-send-email-lersek@redhat.com>
In-Reply-To: <1409532820-5027-3-git-send-email-lersek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Laszlo Ersek <lersek@redhat.com>
Cc: linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, msalter@redhat.com

On Mon, 01 Sep, at 02:53:37AM, Laszlo Ersek wrote:
> +char * __init efi_md_typeattr_format(char *buf, size_t size,
> +				     const efi_memory_desc_t *md)
> +{
> +	char *pos;
> +	int type_len;
> +	register u64 attr;

You can delete the 'register' keyword, since the compiler is free to
ignore it (and will do so).

Rest of the patch looks good.

-- 
Matt Fleming, Intel Open Source Technology Center
