From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 21 Apr 2003 20:38:31 +0000
Subject: Re: [Linux-ia64] 32 bit syscall unification in 2.5
Message-Id: <marc-linux-ia64-105590723705582@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705570@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705570@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 21 Apr 2003 13:25:53 -0700, Arun Sharma <arun.sharma@intel.com> said:

  Arun> Perhaps, I can refine my change to kernel/sys.c a bit:

  Arun> -#if !defined(__ia64__) && !defined(CONFIG_V850)
  Arun> +#if (!defined(__ia64__) && !defined(CONFIG_V850)) || defined(CONFIG_COMPAT)

  Arun> This has the advantage of not having sys_old_getrlimit() for ia64
  Arun> kernels that don't have ia32 support.

Yes, this I like better, too.  Would you mind sending me an updated patch?

Thanks,

	--david

