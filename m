From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 22 Oct 2003 22:47:13 +0000
Subject: Re: make X server on zx2000 (and probably others) work again
Message-Id: <marc-linux-ia64-106686296915643@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106678442302747@msgid-missing>
In-Reply-To: <marc-linux-ia64-106678442302747@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 21, 2003 at 05:59:58PM -0700, David Mosberger wrote:
> In recent 2.5/6 kernels, the X server on my zx2000/Radeon workstation
> would cause a crash.  Turns out this is due to a long-standing bug in
> efi.c: the range checking in efi_mem_type() and efi_mem_attributes()
> could cause an underflow if the size of a memory descriptor is zero
> (as happens sometimes due to memory trimming).  In my case, granule
> zero had a zero size and that in turn caused all /dev/mem mappings to
> occur with WRITE-BACK mapping, which doesn't make the X server happy
> (instant MCA on a zx2000, for example).
> 
> Note that this bug existed for a long time, so it's possible that
> there may have been other subtle memory-attribute related problems in
> the past.  This bug just became more noticable recently, since the
> /dev/mem driver now completely ignores the O_SYNC flag and relies
> totally on the value returned by efi_mem_attributes().
> 

I have a very strange problem with my bigsur. Whenever I put a new
kernel on it, it would crash at random without any warnings during boot
after a warm reboot. I had to power cycle it to get it to boot. After
applying this patch to 2.4.21, I have rebooted it twice without
powering it down first.


H.J.
