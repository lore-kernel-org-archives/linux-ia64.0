From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 25 Jun 2003 16:53:26 +0000
Subject: Re: IA-32 support patch: fcntl64 calls are broken
Message-Id: <marc-linux-ia64-105656005104192@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105649509512709@msgid-missing>
In-Reply-To: <marc-linux-ia64-105649509512709@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 24 June 2003 4:51 pm, Arun Sharma wrote:
> Currently, sys32_fcntl64() is broken, because it passes F_*64 commands to sys_fcntl(), which it doesn't understand. The F_XXX64 commands need to be converted to F_XXX before calling sys_fcntl().
> 
> We also eliminated a copy, because the 32 bit struct flock64 and the 64 bit struct flock seem to be identical.
> 
> This patch is relevant only to 2.4, as it has already been taken care of in 2.5.

2.5 has this code, which looks suspicious to me (do we really mean
to call sys_fcntl() twice?):

        case F_GETLK64:
        case F_SETLK64:
        case F_SETLKW64:
                ret = get_compat_flock64(&f, compat_ptr(arg));
                if (ret != 0)
                        break;
                old_fs = get_fs();
                set_fs(KERNEL_DS);
                ret = sys_fcntl(fd, F_GETLK, (unsigned long)&f);
                ret = sys_fcntl(fd, (cmd = F_GETLK64) ? F_GETLK :
                                ((cmd = F_SETLK64) ? F_SETLK : F_SETLKW),
                                (unsigned long)&f);

