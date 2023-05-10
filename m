From: Matthew Wilcox <willy@infradead.org>
Date: Wed, 10 May 2023 06:07:15 +0000
Subject: Re: [PATCH 00/23] arch: allow pte_offset_map[_lock]() to fail
Message-Id: <ZFs0k2rrLPH9A/UU@casper.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <77a5d8c-406b-7068-4f17-23b7ac53bc83@google.com>
In-Reply-To: <77a5d8c-406b-7068-4f17-23b7ac53bc83@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Hildenbrand <david@redhat.com>, Suren Baghdasaryan <surenb@google.com>, Qi Zheng <zhengqi.arch@bytedance.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Helge Deller <deller@gmx.de>, John David Anglin <dave.anglin@bell.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Alexandre Ghiti <alexghiti@rivosinc.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Claudio Imbrenda <imbrenda@linux.ibm.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 09, 2023 at 09:39:13PM -0700, Hugh Dickins wrote:
> Two: pte_offset_map() will need to do an rcu_read_lock(), with the
> corresponding rcu_read_unlock() in pte_unmap().  But most architectures
> never supported CONFIG_HIGHPTE, so some don't always call pte_unmap()
> after pte_offset_map(), or have used userspace pte_offset_map() where
> pte_offset_kernel() is more correct.  No problem in the current tree,
> but a problem once an rcu_read_unlock() will be needed to keep balance.

Hi Hugh,

I shall have to spend some time looking at these patches, but at LSFMM
just a few hours ago, I proposed and nobody objected to removing
CONFIG_HIGHPTE.  I don't intend to take action on that consensus
immediately, so I can certainly wait until your patches are applied, but
if this information simplifies what you're doing, feel free to act on it.
