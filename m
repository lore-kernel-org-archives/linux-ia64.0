From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 10 Sep 2004 07:35:21 +0000
Subject: Re: [RFC 1/2] Add SN2 Special Memory driver.
Message-Id: <20040910083521.B21519@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040909175339.GA23863@lnx-holt.americas.sgi.com>
In-Reply-To: <20040909175339.GA23863@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 09, 2004 at 12:53:39PM -0500, Robin Holt wrote:
> 
> Really, this is a 2 part patch and not a 4 part.
> 
> Rename the fetchop.h to mspec.h.
> 
> Index: linux-2.6/include/asm-ia64/sn/mspec.h
> =================================> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6/include/asm-ia64/sn/mspec.h	2004-08-31 12:13:43.000000000 -0500
> @@ -0,0 +1,85 @@
> +/*
> + *
> + * This file is subject to the terms and conditions of the GNU General Public
> + * License.  See the file "COPYING" in the main directory of this archive
> + * for more details.
> + *
> + * Copyright (c) 2001-2003 Silicon Graphics, Inc.  All rights reserved.
> + */
> +
> +#ifndef _ASM_IA64_SN_FETCHOP_H
> +#define _ASM_IA64_SN_FETCHOP_H

These don't match the filename.

> +
> +#include <linux/config.h>
> +
> +#define FETCHOP_BASENAME	"sgi_fetchop"
> +#define FETCHOP_FULLNAME	"/dev/sgi_fetchop"

This doesn't belong into a kernel header.

> +/*
> + * Convert a region 6 (kaddr) address to the address of the fetchop variable
> + */
> +#define FETCHOP_KADDR_TO_MSPEC_ADDR(kaddr)	TO_MSPEC(kaddr)

Why this wrapper?

