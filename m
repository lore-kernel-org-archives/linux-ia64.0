From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Mon, 28 Oct 2002 00:51:19 +0000
Subject: Re: [Linux-ia64] quick ia64 patch for 2.5.44 (UP only)
Message-Id: <marc-linux-ia64-105590709805266@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805243@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805243@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On Mon, 28 Oct 2002 10:57:17 +1100
Peter Chubb <peter@chubb.wattle.id.au> wrote:

> >>>>> "Kimio" = Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp> writes:
> 
> Kimio> Hi Erich,
> Kimio> Here is the patch.
> Kimio> I changed cpu_init() in setup.c so that BSP prepares
> Kimio> per_cpu data for all CPUS.
> 
> After applying this patch, I can boot on SMP.  However, the machine
> hangs on shutdown
> 
> ...
> Deconfiguring network interfaces... done.
> Deactivating swap... done.
> Unmounting local filesystems... done.
> Rebooting... Shutting down devices

I have a same problem on Bigsur since 2.5.39.
So the problem caused by another bug.

I've heard a rumor that this patch might fix it, but I haven't
test it, yet.

http://marc.theaimsgroup.com/?l=linux-kernel&m3371059120183&w=2

> so there's still something wrong, not sure what (as interrupts are
> disabled, I can't use the magic sysrq key to find out what's
> happening)

Keyboard cannot be used on my Bigsur since 2.5.3? also.
I've heard that there was a same problem at early 2.4.

Thanks,
Kimi

-- 
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>


