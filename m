From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 20 Nov 2008 01:20:07 +0000
Subject: Re: ia64: linux-next allmodconfig
Message-Id: <alpine.DEB.1.10.0811192014510.15348@gandalf.stny.rr.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081119165028.ed07b078.akpm@linux-foundation.org>
In-Reply-To: <20081119165028.ed07b078.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Wed, 19 Nov 2008, Andrew Morton wrote:

> 
> arch/ia64/kernel/built-in.o(.text+0x4a22): In function `efi_initialize_iomem_resources':
> : undefined reference to `__ia64_save_stack_nonlocal'
> arch/ia64/kernel/built-in.o(.text+0x16262): In function `pfm_context_create':
> : undefined reference to `__ia64_save_stack_nonlocal'
> arch/ia64/kernel/built-in.o(.text+0x238a2): In function `sys_perfmonctl':
> : undefined reference to `__ia64_save_stack_nonlocal'
> arch/ia64/kernel/built-in.o(.text+0x466c2): In function `dup_state_stack':
> : undefined reference to `__ia64_save_stack_nonlocal'
> arch/ia64/kernel/built-in.o(.text+0x46cf2): In function `desc_prologue':
> : undefined reference to `__ia64_save_stack_nonlocal'
> arch/ia64/kernel/built-in.o(.text+0x49752): more undefined references to `__ia64_save_stack_nonlocal' follow
> 
> Whatever caused this is fairly well hidden from `grep'..
> 

That looks like some builtin function that gcc might add. I've seen other 
types of references before like that on x86. Can't remember what it was 
exactly, but it hit me when I had two slightly different compilers in my 
distcc farm.

/me goes looks at his http://rostedt.homelinux.com/distcc/ page.

Ah, here it is...

  Found that -fstack-protect-all set will cause the cross compiler to 
  create "stack_chk_guard" calls. These are not defined in the kernel and 
  cause linking problems.

Not sure if __ia64_save_stack_nonlocal is equivalent, but perhaps it is 
related. Maybe some CFLAG was set that caused an issue?

-- Steve

