From: Noah Romer <nromer@lsil.com>
Date: Wed, 15 Aug 2001 20:30:17 +0000
Subject: Re: [Linux-ia64] rwlock and atomic_sub on ia64
Message-Id: <marc-linux-ia64-105590698805083@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805063@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805063@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
>On Tue, 14 Aug 2001 16:00:39 -0500, Noah Romer <nromer@lsil.com> said:
>   Noah> Yes, but how do I get to it? I finally found the ia64
>   Noah> implementation of write_lock and read_lock for SMP systems
>   Noah> (which is what I'm compiling on).(1) However, when I try to
>   Noah> compile the driver I get a
> 
>   Noah>    warning: implicit declaration of function `rwlock_init'
> 
>   Noah> message. I have <linux/spinlock.h> included, and that's been
>   Noah> enough up until now. Is there someother include file I need
>   Noah> under the ia64 arch?
> 
> No, that seems to be a genuine omission.  rwlock_init() was added in
> the 2.4.0 test series and I seem to have missed that.  There aren't
> too many drivers that use it.  Anyhow, the fix is trivial.  Something
> along the lines of:
> 
> --- include/asm-ia64/spinlock.h~	Tue Aug 14 00:06:43 2001
> +++ include/asm-ia64/spinlock.h	Wed Aug 15 11:31:24 2001
> @@ -108,6 +108,8 @@
>  } rwlock_t;
>  #define RW_LOCK_UNLOCKED (rwlock_t) { 0, 0 }
>  
> +#define rwlock_init(x) do { *(x) = RW_LOCK_UNLOCKED; } while(0)
> +
>  #define read_lock(rw)					\
>  do {								\
>  	int tmp = 0;						\
> 
> should do the trick.

Yep, that fixes it. I never even noticed that rwlock_init wasn't 
defined, just saw read_lock, write_lock and rwlock_t and assumed 
rwlock_init was there. My bad. Thanks.

On another note, I'm still a little puzzled by the warnings I got when 
using atomic_sub. I was passing a u8 value in as the amount to be 
subtracted, and got four

    mptlan.c:1135: warning: comparison is always false due to limited 
range of data type

Now, I can make the warning go away by changing the variable to an int 
(but not by casting the u8 to an int), but it seems odd that gcc would 
complain about the size of a u8 variable making the comparison always 
false. I started poking around in the output for other drivers, and 
found the above warning for all sorts of code (a lot of it involving bh 
data types). This is probably a question for the gcc folks, but . . . ;)

-- 
Noah Romer
Driver Developer, CM gopher and Linux Whipping Boy
Storage Components Firmware
LSI Logic Corp.


