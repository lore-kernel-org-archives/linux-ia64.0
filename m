From: Don Dugger <n0ano@valinux.com>
Date: Tue, 16 Jan 2001 16:22:29 +0000
Subject: Re: [Linux-ia64] Re: status of debugging ia32 executables on ia64
Message-Id: <marc-linux-ia64-105590693005052@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005044@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005044@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jose-

`syscall #29' is `pause' which has been implemented, you're just running
on an older version of the kernel that doesn't have it.

I curious about `strace' failing, I haven't seen that before.  Do you get
any output from `strace' at all and, if so, could you send me a copy?

Tnx.

On Tue, Jan 16, 2001 at 05:01:06PM +0100, Jose Luu wrote:
> 
> Thanks Don,
> 
> I am reporting full success with gdb 5.0 (taken as is from ia32 suse 7.0),
> and I have been able to debug my problem.
> 
> I have had less success with strace which did not let the executable run
> (killed by SIGSGV), and I also got in the log file:
> IA32 syscal #29 issued, may be we should implement it. (what call is it ?)
> 
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

