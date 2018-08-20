From: Michal Hocko <mhocko@kernel.org>
Date: Mon, 20 Aug 2018 07:17:30 +0000
Subject: Re: [PATCH v6 00/11] hugetlb: Factorize hugetlb architecture primitives
Message-Id: <20180820071730.GC29735@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180806175711.24438-1-alex@ghiti.fr>
 <81078a7f-09cf-7f19-f6bb-8a1f4968d6fb@ghiti.fr>
In-Reply-To: <81078a7f-09cf-7f19-f6bb-8a1f4968d6fb@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

On Mon 20-08-18 08:45:10, Alexandre Ghiti wrote:
> Hi Michal,
> 
> This patchset got acked, tested and reviewed by quite a few people, and it
> has been suggested
> that it should be included in -mm tree: could you tell me if something else
> needs to be done for
> its inclusion ?
> 
> Thanks for your time,

I didn't really get to look at the series but seeing an Ack from Mike
and arch maintainers should be good enough for it to go. This email
doesn't have Andrew Morton in the CC list so you should add him if you
want the series to land into the mm tree.
-- 
Michal Hocko
SUSE Labs
