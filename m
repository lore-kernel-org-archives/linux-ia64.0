From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 16 Jun 2004 17:28:22 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality
Message-Id: <20040616172822.GA15988@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> +	default m if (IA64_SGI_SN2 || IA64_GENERIC)

really?

> +#ifndef SN_PROM
> +#include <linux/kernel.h>
> +#include <linux/interrupt.h>
> +#include <linux/module.h>
> +#include <asm/sn/intr.h>
> +#include <asm/sn/sn_sal.h>
> +#include <asm/sn/xp.h>
> +#else /* ! SN_PROM */
> +#include "xp.h"
> +#include "xpc_stubs.h"
> +#endif /* ! SN_PROM */

Please kill all the prom compat gunk.  Once non-SGI people touch it you can't
easily merge it back anyway for license reasons.

> +
> +
> +/*
> + * Initialize the XPC interface to inidicate that XPC isn't loaded.
> + */
> +static xpc_t xpc_notloaded(void) { return xpcNotLoaded; }
> +
> +xpc_interface_t xpc_interface = {
> +	(void (*)(int)) xpc_notloaded,
> +	(void (*)(int)) xpc_notloaded,
> +	(xpc_t (*)(partid_t, int, u32, void **)) xpc_notloaded,
> +	(xpc_t (*)(partid_t, int, void *)) xpc_notloaded,
> +	(xpc_t (*)(partid_t, int, void *, xpc_notify_func_t, void *))
> +								xpc_notloaded,
> +	(void (*)(partid_t, int, void *)) xpc_notloaded,
> +	(xpc_t (*)(partid_t, void *)) xpc_notloaded
> +};

Yikes.  So you define a method table where only one possible provider exists
anyway?  Please merge xp and xpc into a single module and get rid off all this
junk.

> +#ifdef CONFIG_KDB
> +
> +static void
> +xpc_kdb_print_users(xpc_registration_t *registration, int ch_number)
> +{
> +	kdb_printf("xpc_registrations[channel=%d] (0x%p):\n", ch_number,
> +							(void *) registration);
> +
> +	kdb_printf("\t&sema=0x%p\n", (void *) &registration->sema);
> +	kdb_printf("\tfunc=0x%p\n", (void *) registration->func);
> +	kdb_printf("\tkey=0x%p\n", registration->key);
> +	kdb_printf("\tnentries=%d\n", registration->nentries);
> +	kdb_printf("\tmsg_size=%d\n", registration->msg_size);
> +	kdb_printf("\tassigned_limit=%d\n", registration->assigned_limit);
> +	kdb_printf("\tidle_limit=%d\n", registration->idle_limit);
> +}

IIRC Keith objected against adding kdb-related code to mainline in the past.
And IMHO it's indeed better placed in the kdb patch.

> +	XP_ASSERT(ch_number >= 0 && ch_number < XPC_NCHANNELS);
> +	XP_ASSERT(payload_size != 0 && nentries != 0);
> +	XP_ASSERT(func != NULL);
> +	XP_ASSERT(assigned_limit != 0 && idle_limit <= assigned_limit);

Please use BUG_ON()

> +	xpc_registration_t *registration;

An d btw, please get rid of all these awfull typedefs.

> +/*
> + * Wrapper for bte_copy() that should it return a failure status will retry
> + * the bte_copy() once in the hope that the failure was due to a temporary
> + * aberration (i.e., the link going down temporarily).
> + *
> + * See bte_copy for definition of the input parameters.
> + */
> +static __inline__ bte_result_t
> +xp_bte_copy(u64 src, u64 dest, u64 len, u64 mode, void *notification)
> +{
> +	bte_result_t ret;
> +
> +
> +	ret = bte_copy(src, dest, len, mode, notification);
> +
> +	if (ret != BTE_SUCCESS) {
> +		if (!in_interrupt()) {
> +			cond_resched();
> +		}

If you're ever calling this from under a spinlock you're screwed..

> + * 
> + *    CHANNEL | USER          | PURPOSE                                  
> + *   ---------+---------------+---------------------------------------------
> + *    0       | XPMEM         | cross partition memory driver
> + *   ---------+---------------+---------------------------------------------

What's that?  Can't find it in your driver submission.

> +typedef struct {
> +	volatile u8 flags;	/* FOR XPC INTERNAL USE ONLY */

volatile is always a BIG warning sign.  What does it try to do?

> +//>>> is inline a good idea with all the strings?
> +static __inline__ char *
> +xpc_get_ascii_reason_code(xpc_t reason)

No.

> Index: linux/include/asm-ia64/sn/xp_dbgtk.h
> =================================> --- linux.orig/include/asm-ia64/sn/xp_dbgtk.h	1969-12-31 18:00:00.000000000 -0600
> +++ linux/include/asm-ia64/sn/xp_dbgtk.h	2004-04-23 12:55:57.000000000 -0500
> @@ -0,0 +1,52 @@
> +/*
> + * This file is subject to the terms and conditions of the GNU General Public
> + * License.  See the file "COPYING" in the main directory of this archive
> + * for more details.
> + *
> + * Copyright (C) 2004 Silicon Graphics, Inc. All rights reserved.
> + */
> +
> +
> +/*
> + * Cross Partition (XP)'s dbgtk related definitions.
> + */
> +
> +
> +#ifndef _ASM_IA64_SN_XP_DBGTK_H
> +#define _ASM_IA64_SN_XP_DBGTK_H
> +
> +
> +#if defined(CONFIG_DBGTK) || defined(CONFIG_DBGTK_MODULE)
> +
> +#include <linux/dbgtk.h>
> +
> +#else /* defined(CONFIG_DBGTK) || defined(CONFIG_DBGTK_MODULE) */
> +
> +#define DECLARE_DPRINTK(_mn, _hl, _dcs, _dps, _sd)
> +#define EXTERN_DPRINTK(_mn)
> +#define REG_DPRINTK(_mn)
> +#define UNREG_DPRINTK(_mn)
> +#define DPRINTK(_mn, mask, fmt...)
> +#define DPRINTK_ALWAYS(_mn, mask, fmt...) printk(fmt)

Bah, please kill all that crap.

