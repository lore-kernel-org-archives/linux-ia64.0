From: Matthew Wilcox <willy@debian.org>
Date: Tue, 08 Jul 2003 19:16:47 +0000
Subject: Re: IA-32 support patch: fcntl64 calls are broken
Message-Id: <marc-linux-ia64-105769189204760@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105649509512709@msgid-missing>
In-Reply-To: <marc-linux-ia64-105649509512709@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 08, 2003 at 11:57:21AM -0700, Arun Sharma wrote:
> --- linux/arch/ia64/ia32/sys_ia32.c-	Tue Jun 24 15:43:39 2003
> +++ linux/arch/ia64/ia32/sys_ia32.c	Tue Jul  1 14:09:27 2003
> @@ -3622,9 +3622,11 @@
>  			return -EFAULT;
>  		old_fs = get_fs();
>  		set_fs(KERNEL_DS);
> -		ret = sys_fcntl(fd, cmd, (unsigned long) &f);
> +                ret = sys_fcntl(fd, (cmd = F_GETLK64) ? F_GETLK :

looks like you're using spaces instead of tabs.  tsk.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
