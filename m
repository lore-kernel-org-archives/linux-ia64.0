From: "H . J . Lu" <hjl@valinux.com>
Date: Sat, 09 Sep 2000 21:33:01 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.0-test8)
Message-Id: <marc-linux-ia64-105590678205473@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Sep 09, 2000 at 01:49:53PM -0700, David Mosberger wrote:
> >>>>> On Sat, 9 Sep 2000 12:07:44 -0700, "H . J . Lu" <hjl@valinux.com> said:
> 
>   HJ> I tried it on my UP Big Sur with BIOS Build 59 and B1 stepping
>   HJ> CPU.  It didn't work. I got
> 
>   HJ> Unexpected irq vector 0x0 on CPU 0!
> 
> We also do not have any B1 Big Sur, so it's not something I can test.
> However, the "Unexpected irq" is normal, it's even in the bootlog you
> included.
> 
>   HJ> as soon as it booted. I am enclosing my .config here. BTW, the
>   HJ> kernel from the 0828 Turbo Linux booted fine. I am enclosing the
>   HJ> boot message here also. Any ideas?
> 
> You didn't describe how the new kernel failed, so there isn't much I
> can do.

It keeps printing

Unexpected irq vector 0x0 on CPU 0!

and nothing else. I don't think boot is finished.


-- 
H.J. Lu (hjl@gnu.org)

