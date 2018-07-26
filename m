From: Helge Deller <deller@gmx.de>
Date: Thu, 26 Jul 2018 12:59:40 +0000
Subject: Re: [PATCH v4 00/11] hugetlb: Factorize hugetlb architecture primitives
Message-Id: <20180726125940.GA15033@ls3530>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180705110716.3919-1-alex@ghiti.fr>
 <20180709141621.GD22297@dhcp22.suse.cz>
 <2173685f-7f85-7acb-4685-2383210c5fa2@ghiti.fr>
 <87d0vehx16.fsf@concordia.ellerman.id.au>
 <67aba0f0-c0d4-b06f-5fbc-f4d113ce5033@ghiti.fr>
In-Reply-To: <67aba0f0-c0d4-b06f-5fbc-f4d113ce5033@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Alex Ghiti <alex@ghiti.fr>
Cc: linux-mips@linux-mips.org, dalias@libc.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, benh@kernel.crashing.org, will.deacon@arm.com, Michal Hocko <mhocko@kernel.org>, paulus@samba.org, hpa@zytor.com, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, ysato@users.sourceforge.jp, Michael Ellerman <mpe@ellerman.id.au>, deller@gmx.de, x86@kernel.org, linux@armlinux.org.uk, mingo@redhat.com, catalin.marinas@arm.com, jhogan@kernel.org, jejb@parisc-linux.org, fenghua.yu@intel.com, arnd@arndb.de, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, tony.luck@intel.com, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, ralf@linux-mips.org, paul.burton@mips.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net, Mike Kravetz <mike.kravetz@oracle.com>

* Alex Ghiti <alex@ghiti.fr>:
> This is the result of the build for all arches tackled in this series
> rebased on 4.18-rc6:
> ...
> parisc:
> =A0=A0=A0=A0=A0=A0=A0 generic-64bit_defconfig: with huge page does not li=
nk
> =A0=A0=A0=A0=A0=A0=A0 generic-64bit_defconfig: without huge page does not=
 link
> =A0=A0=A0=A0=A0=A0=A0 BUT not because of this series, any feedback welcom=
e.
Strange, but I will check that later....

Anyway, I applied your v4-patch to my parisc64 tree, built the kernel,
started it and ran some hugetlb LTP testcases sucessfully.
So, please add:

Tested-by: Helge Deller <deller@gmx.de> # parisc

Helge
