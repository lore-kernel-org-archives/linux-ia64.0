From: Arun Sharma <arun.sharma@intel.com>
Date: Mon, 21 Apr 2003 20:25:53 +0000
Subject: Re: [Linux-ia64] 32 bit syscall unification in 2.5
Message-Id: <marc-linux-ia64-105590723705581@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705570@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705570@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Randolph Chung <randolph@tausq.org> writes:
> 
> Arun's looks good. I'm not sure what the bit in kernel/sys.c is about
> though, but I trust he has his reasons for adding it :-)
> 

The code doesn't compile without the change to kernel/sys.c. 
kernel/compat.c makes an unconditional reference to
sys_old_getrlimit(), which doesn't exist on ia64.

Perhaps, I can refine my change to kernel/sys.c a bit:

-#if !defined(__ia64__) && !defined(CONFIG_V850)
+#if (!defined(__ia64__) && !defined(CONFIG_V850)) || defined(CONFIG_COMPAT)

This has the advantage of not having sys_old_getrlimit() for ia64
kernels that don't have ia32 support.

        -Arun 


