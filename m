From: Don Dugger <n0ano@valinux.com>
Date: Mon, 15 Jan 2001 19:57:01 +0000
Subject: Re: [Linux-ia64] status of debugging ia32 executables on ia64
Message-Id: <marc-linux-ia64-105590693005045@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005043@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005043@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jose-

I've found all of my IA32 problems with one of two tools.

1)  `strace'.  The IA64 version will also trace an IA32 program
so you can just use it as you normally would.  Most failures these
days are from bad system calls that should be identified by this tool.

2)  The IA32 version of `gdb' should work.  If `gdb' from a generic
IA32 system doesn't work let me know, I've got a version that I've
created that I know works.

Check your system log to make sure there aren't any funny messages.  If
you program makes a call we haven't implemented yet a message will be
printed to the console.

Also, are you running the EFI `wkaround' program before you boot your
kernel?  There are still some CPU erratas that affect IA32 execute that
are solved by this program.

On Mon, Jan 15, 2001 at 08:19:36PM +0100, Jose Luu wrote:
> 
> Hi,
> 
> I have a non functional ia32 executable (which of course works well on a
> regular ia32 machine).
> 
> What are my options for debugging it ?
> 
> There has a message from Don in march 2000 on an attempt to make gdb work
> for ia32 executables, since then no news, do we have a status on this ? What
> would be involved to make gdb work ?
> 
> Thanks
> Jose
> 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

