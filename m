From: Don Dugger <n0ano@valinux.com>
Date: Mon, 07 May 2001 16:09:07 +0000
Subject: Re: [Linux-ia64] IA32 process segfaults on exit
Message-Id: <marc-linux-ia64-105590693005539@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005442@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005442@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mike-

Well, I'll very confused.  I thought your problem was some registers
that we stopped initializing that the LIBC startup code expected to
point to an exit handler.  I spent over a week debugging my initialization
code (the register was always non-zero in user mode) only to disciver
today that when I link the process static everything works fine, including
your test program.  When I try and run a dynamic program the initial
registers are bogus.  (Did I ever mention that I HATE dynamic linking.)

Bottom line is I still don't know what the problem is but I think I'm
making progress.

On Fri, Apr 20, 2001 at 09:46:06AM -0700, Michael Madore wrote:
> Hi,
> 
> The attached 32 bit code will run without error on IA32, but the same binary
> will generate the following errors when it returns on IA64.
> 
> sizeof(elf_gregset_t) (1024) != sizeof(struct pt_regs) (400)
> Segmentation fault (core dumped)
> 
> Is this expected behavior?
> 
> -- 
> Mike Madore
> Software Engineer
> TurboLinux, Inc.
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

