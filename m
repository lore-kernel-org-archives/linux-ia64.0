From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 21 Apr 2004 01:37:23 +0000
Subject: RE: [PATCH][RFC] Vector sharing
Message-Id: <MDEEKOKJPMPMKGHIFAMAEEBNDNAA.kaneshige.kenji@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <MDEEKOKJPMPMKGHIFAMAOENCDMAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAOENCDMAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> I have a patch in the works that will clean up ACPI _PRT handling
> (it removes the boot-time _PRT parsing and does the IOSAPIC setup
> at pci_enable_device()-time).  One side effect is that we only set
> up vectors for interrupt lines actually used.

I know your patch setting up vectors for interrupt lines actually used :)
But as I said in the previous mail, I think vector sharing is necessary
to solve the problem (lack of vectors).

Thanks,
Kenji Kaneshige

