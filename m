From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Mon, 22 Jul 2002 23:54:23 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905805@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On Sat, 20 Jul 2002 00:08:22 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> The latest ia64 kernel patch is at
> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/ in file:
> 
>         linux-2.4.18-ia64-020719.diff.gz

In this version, my system doesn't boot without increasing swiotlb.
It was able to boot with default swiotlb in the previous version.

I found eepro100 driver was trying to get swiotlb of
(0x610 bytes * 1024 = 0x184000) at booting, and this caused
swiotlb shortage.

I guess the problem might be caused by this modification;

> - Include eepro1000 and Tigon3 support (various, plus bug fixes by
>   Grant Grundler for these and other gigE cards)

In linux-2.4.18/drivers/net/eepro100.c, RX_RING_SIZE is changed to 1024!!

-------------
 /* A few values that may be tweaked. */
 /* The ring sizes should be a power of two for efficiency. */
-#define TX_RING_SIZE   32
-#define RX_RING_SIZE   32
+#define TX_RING_SIZE   64
+#define RX_RING_SIZE   1024
--------------

If this modification is permanent, I think default value of swiotlb
should be increased. Any comment?

Regards,
Kimi

-- 
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>


