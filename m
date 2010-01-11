From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 11 Jan 2010 18:23:30 +0000
Subject: RE: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be
Message-Id: <987664A83D2D224EAE907B061CE93D530C60E95E@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>        printk(KERN_INFO PFX "Detected HP ZX1 %s AGP chipset "
>                "(ioc=%llx, lba=%llx)\n", (char *)context,
>                sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa);
>
>If hp_zx1_setup returned 0, we should see the "Detected HP ZX1
>HWP0003 AGP chipset" message next, but we don't

Perhaps KERN_INFO is below the priority level of kernel
messages being logged?

-Tony
