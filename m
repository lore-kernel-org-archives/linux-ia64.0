From: Keith Owens <kaos@sgi.com>
Date: Wed, 05 Mar 2003 00:33:33 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-021210 misaligned sal error record
Message-Id: <marc-linux-ia64-105590709805967@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805925@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805925@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 4 Mar 2003 16:01:20 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>Below is a proposed patch (btw: I think your patch had a bug:
>addr_processor_static_info() didn't skip the cpuid structure).

No bug, I start with ((char *) &(p->processor_static_info)) so gcc has
already factored in the size of cpuid_info.  Your patch removes
cpuid_info from sal_log_processor_info_t so your calculation has to add
sizeof(cpuid_info) back in.

My patch gives accurate kdb backtraces for MCA and INIT monarch so I
know the alignments are correct.  kdb v4.0, work in progress.

>+/* Given a sal_log_processor_info_t pointer, return a pointer to the processor_static_info: */
>+#define SAL_LPI_PSI_INFO(l)								\
>+({	sal_log_processor_info_t *_l = (l);						\
>+	((sal_processor_static_info_t *)						\
>+	 ((char *) _l + ((_l->valid.num_cache_check + _l->valid.num_tlb_check		\
>+			  + _l->valid.num_bus_check + _l->valid.num_reg_file_check	\
>+			  + _l->valid.num_ms_check) * sizeof(sal_log_mod_error_info_t)	\
>+			 + sizeof(struct sal_cpuid_info))));				\
>+})

Linus recommends static inline instead of #define unless there is no
choice.  static inline does type checking, #define does not.

static inline
sal_processor_static_info_t *SAL_LPI_PSI_INFO(sal_log_processor_info_t *l)
{
	sal_processor_static_info_t *s 	(sal_processor_static_info_t *)(
		(char *) l +
		  (l->valid.num_cache_check +
		   l->valid.num_tlb_check +
		   l->valid.num_bus_check +
		   l->valid.num_reg_file_check +
		   l->valid.num_ms_check
		  ) * sizeof(sal_log_mod_error_info_t) +
		sizeof(struct sal_cpuid_info)
	);
	return s;
}

>Could someone test this to verify it works as intended (it does
>compile, but that's as far as I tested it).

Testing with kdb v4.0 now.


