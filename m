From: Dean Nelson <dcn@sgi.com>
Date: Thu, 12 Aug 2004 15:10:28 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040812151028.GA5751@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 10, 2004 at 02:54:00PM -0500, Dean Nelson wrote:
>
> Tony,
> 
> I'm interested in your response to what Robin wrote. Care to comment?
> 
> And just another data point: we no longer need the sal_lock exported,
> just ia64_sal, does this affect your thoughts on this matter?

Just wanted to add a couple of additional data points to the
discussion of whether or not to export the SAL call itself.

It was pointed out to me that the PAL call is exported. You
can find PAL_CALL() in include/asm-ia64/pal.h and its export
in arch/ia64/kernel/ia64_ksyms.c, where the necessary symbols
are exported:
                                                                                
        ia64_pal_call_static
        ia64_load_scratch_fpregs
        ia64_save_scratch_fpregs
                                                                                
(The latter two are needed by SAL_CALL(), which also requires
the exporting of ia64_sal and sal_lock.)
                                                                                
Is there a fundamental difference between PAL and SAL that would
justify exporting one and not the other?
                                                                                
Also, what makes it okay for 'CONFIG_IA64_SGI_SN_XPC=y' to make a
SAL_CALL() and not okay for 'CONFIG_IA64_SGI_SN_XPC=m'? It's the
same code, either compiled into the kernel or into a kernel module.
What makes the first one 'trustworthy' and the second one not?

Thanks,
Dean

