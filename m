From: Arun Sharma <arun.sharma@intel.com>
Date: Wed, 25 Jun 2003 18:18:17 +0000
Subject: Re: IA-32 support patch: fcntl64 calls are broken
Message-Id: <marc-linux-ia64-105656528910513@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105649509512709@msgid-missing>
In-Reply-To: <marc-linux-ia64-105649509512709@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:
> 2.5 has this code, which looks suspicious to me (do we really mean
> to call sys_fcntl() twice?):

Cc'ing the author of this patch in 2.5. Stephen, did you mean to call sys_fcntl() twice ?

	-Arun

> 
>         case F_GETLK64:
>         case F_SETLK64:
>         case F_SETLKW64:
>                 ret = get_compat_flock64(&f, compat_ptr(arg));
>                 if (ret != 0)
>                         break;
>                 old_fs = get_fs();
>                 set_fs(KERNEL_DS);
>                 ret = sys_fcntl(fd, F_GETLK, (unsigned long)&f);
>                 ret = sys_fcntl(fd, (cmd = F_GETLK64) ? F_GETLK :
>                                 ((cmd = F_SETLK64) ? F_SETLK : F_SETLKW),
>                                 (unsigned long)&f);
> 


