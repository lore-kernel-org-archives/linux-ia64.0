From: "H . J . Lu" <hjl@valinux.com>
Date: Sat, 09 Sep 2000 21:49:52 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.0-test8)
Message-Id: <marc-linux-ia64-105590678205475@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Sep 09, 2000 at 02:45:15PM -0700, David Mosberger wrote:
> >>>>> On Sat, 9 Sep 2000 14:33:01 -0700, "H . J . Lu" <hjl@valinux.com> said:
> 
>   HJ> It keeps printing
> 
>   HJ> Unexpected irq vector 0x0 on CPU 0!
> 
>   HJ> and nothing else. I don't think boot is finished.
> 
> Do you happen to have any USB devices plugged in?  If so, try
> unplugging them.

I don't have any USB devices.

> 
> Also, did you make sure you ran "make dep" before building the kernel
> to ensure include/asm-ia64/offsets.h is up-to-date?
> 

Yes, I did "make dep". What should include/asm-ia64/offsets.h look
like? That may explain many things.


-- 
H.J. Lu (hjl@gnu.org)

