From: "Haavard Skinnemoen" <hskinnemoen@gmail.com>
Date: Thu, 31 Aug 2006 18:41:04 +0000
Subject: Re: [RFC][PATCH 2/9] conditionally define generic get_order() (ARCH_HAS_GET_ORDER)
Message-Id: <1defaf580608311141j39aa87e5ldf80db1db54b2edf@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060830221604.E7320C0F@localhost.localdomain>
	 <20060830221605.CFC342D7@localhost.localdomain>
In-Reply-To: <20060830221605.CFC342D7@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On 8/31/06, Dave Hansen <haveblue@us.ibm.com> wrote:
> diff -puN mm/Kconfig~generic-get_order mm/Kconfig
> --- threadalloc/mm/Kconfig~generic-get_order    2006-08-30 15:14:56.000000000 -0700
> +++ threadalloc-dave/mm/Kconfig 2006-08-30 15:15:00.000000000 -0700
> @@ -1,3 +1,7 @@
> +config ARCH_HAVE_GET_ORDER
> +       def_bool y
> +       depends on IA64 || PPC32 || XTENSA
> +

I have a feeling this has been discussed before, but wouldn't it be
better to let each architecture define this in its own Kconfig?

At some point, I have to add AVR32 to that list, and if one or more
other architectures need to do the same, there will be rejects.

Haavard
