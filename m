From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 26 Apr 2000 21:18:49 +0000
Subject: Re: [Linux-ia64] new kernel diff (relative to 2.3.99-pre5)
Message-Id: <marc-linux-ia64-105590678205056@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205032@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205032@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yup, seems to have been a corrupted kernel.  I compiled the same kernel
with the same .config on an IA32 box with the SGI compilers.  That
kernel seems to work.  I think the toolchain I was compiling with might
be funky.

Thanks,
Jesse

"Seth, Rohit" wrote:
> 
> The kernel binary that you are trying to boot is seeming like corrupted.
> esrly_printk will  not help as eli does not even seem to have passed the
> control to kernel.
>


