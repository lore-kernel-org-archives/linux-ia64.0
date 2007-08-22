From: Jeremy Higdon <jeremy@sgi.com>
Date: Wed, 22 Aug 2007 23:11:11 +0000
Subject: Re: [BUG] 2.6.23-rc3-mm1 Kernel panic - not syncing: DMA: Memory would be corrupted
Message-Id: <20070822231111.GD89849@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46CC48FD.4000607@linux.vnet.ibm.com> <20070822091959.aa38fd3e.akpm@linux-foundation.org> <20070822172541.GA8058@bingen.suse.de> <46CC811C.9010600@linux.vnet.ibm.com> <617E1C2C70743745A92448908E030B2A023B2D39@scsmsx411.amr.corp.intel.com> <46CCB79E.7070109@linux.vnet.ibm.com> <617E1C2C70743745A92448908E030B2A023B2F6A@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A023B2F6A@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org

On Wed, Aug 22, 2007 at 03:56:57PM -0700, Luck, Tony wrote:
> [ 20.903201] [<a0000001003aaa50>] swiotlb_full+0x50/0x120
> [ 20.903202] sp=E00000014322fac0 bsp=E000000143229120
> [ 20.916902] [<a0000001003aac40>] swiotlb_map_single+0x120/0x1c0
> [ 20.916904] sp=E00000014322fac0 bsp=E0000001432290d8
> [ 20.931215] [<a0000001003ab630>] swiotlb_alloc_coherent+0x150/0x240
> [ 20.931217] sp=E00000014322fac0 bsp=E000000143229090
> [ 20.945923] [<a000000100550860>] PrimeIocFifos+0x4c0/0xb20
> [ 20.945925] sp=E00000014322fac0 bsp=E000000143229010
> [ 20.959812] [<a000000100556a80>] mpt_do_ioc_recovery+0xd60/0x28e0
> [ 20.959814] sp=E00000014322faf0 bsp=E000000143228f30
> [ 20.974310] [<a00000010055c8f0>] mpt_attach+0x830/0x20e0
>=20
>=20
> Hmmm!  So you were in the mpt/fusion driver when you ran out
> of SWIOTLB space.  That's an area where we both have the same
> hardware ... and since it booted for me, it means that the
> driver isn't totally broken.
>=20
> I'm totally ignorant of what goes on inside this driver though.
> You have more "ioc's" than I do.  I only see messages from mpt
> bringing up ioc0 & ioc1.  Your boot_log also has ioc2 (which is
> where you crash).  Here's the sdiff(1) output comparing the MPT
> part of your boot log with my successful boot of the same kernel
> and config (your log is the one on the left).  Maybe some MPT/Fusion
> expert can spot something important in this bit?

The more ioc's you have, the more space you will use.

jeremy
