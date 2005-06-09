From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 09 Jun 2005 20:08:08 +0000
Subject: Re: [PATCH] Fix race condition in the rt_sigprocmask fastcall for IA64.
Message-Id: <17064.41384.475688.500958@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506091227350.22827@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506091227350.22827@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Good catch.  Patch looks fine to me.

Thanks,

	--david

>>>>> On Thu, 9 Jun 2005 12:29:10 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:

  current-> blocked will be set to the value of
  current-> thread_info->flags if the cmpxchg to update
  thread_info-> flags fails. For performance reasons the store into
  current-> blocked was placed in the cmpxchg loop. However, the cmpxchg
  Christoph> overwrites the register holding the value to be stored. In the rare
  Christoph> case of a retry the value of thread_info->flags will be written into
  current-> blocked.

  Christoph> The fix is to use another register so that the register containing the
  current-> blocked value is not overwritten.

  Christoph> Signed-off-by: Christoph Lameter <clameter@sgi.com>

  Christoph> Index: linux-2.6.11/arch/ia64/kernel/fsys.S
  Christoph> =================================  Christoph> --- linux-2.6.11.orig/arch/ia64/kernel/fsys.S	2005-03-01 23:38:34.000000000 -0800
  Christoph> +++ linux-2.6.11/arch/ia64/kernel/fsys.S	2005-06-09 11:46:30.000000000 -0700
  Christoph> @@ -460,9 +460,9 @@ EX(.fail_efault, ld8 r14=[r33])			// r14
  Christoph> ;;
 
  Christoph> st8 [r2]=r14				// update current->blocked with new mask
  Christoph> -	cmpxchg4.acq r14=[r9],r18,ar.ccv	// current->thread_info->flags <- r18
  Christoph> +	cmpxchg4.acq r8=[r9],r18,ar.ccv		// current->thread_info->flags <- r18
  Christoph> ;;
  Christoph> -	cmp.ne p6,p0=r17,r14			// update failed?
  Christoph> +	cmp.ne p6,p0=r17,r8			// update failed?
  Christoph> (p6)	br.cond.spnt.few 1b			// yes -> retry
 
  Christoph> #ifdef CONFIG_SMP
