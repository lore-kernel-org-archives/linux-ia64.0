From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Sun, 27 Oct 2002 23:57:17 +0000
Subject: Re: [Linux-ia64] quick ia64 patch for 2.5.44 (UP only)
Message-Id: <marc-linux-ia64-105590709805264@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805243@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805243@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Kimio" = Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp> writes:

Kimio> Hi Erich,
Kimio> Here is the patch.
Kimio> I changed cpu_init() in setup.c so that BSP prepares
Kimio> per_cpu data for all CPUS.

After applying this patch, I can boot on SMP.  However, the machine
hangs on shutdown

...
Deconfiguring network interfaces... done.
Deactivating swap... done.
Unmounting local filesystems... done.
Rebooting... Shutting down devices

so there's still something wrong, not sure what (as interrupts are
disabled, I can't use the magic sysrq key to find out what's
happening)

Peter C

