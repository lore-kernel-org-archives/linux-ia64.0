From: Michal Hocko <mhocko@kernel.org>
Date: Mon, 26 Mar 2018 08:46:50 +0000
Subject: Re: [RFC PATCH v2 0/2] Randomization of address chosen by mmap.
Message-Id: <20180326084650.GC5652@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1521736598-12812-1-git-send-email-blackzert@gmail.com>
 <20180323124806.GA5624@bombadil.infradead.org>
 <651E0DB6-4507-4DA1-AD46-9C26ED9792A8@gmail.com>
In-Reply-To: <651E0DB6-4507-4DA1-AD46-9C26ED9792A8@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Ilya Smith <blackzert@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@synopsys.com, linux@armlinux.org.uk, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, jejb@parisc-linux.org, Helge Deller <deller@gmx.de>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, nyc@holomorphy.com, viro@zeniv.linux.org.uk, arnd@arndb.de, gregkh@linuxfoundation.org, deepa.kernel@gmail.com, Hugh Dickins <hughd@google.com>, kstewart@linuxfoundation.org, pombredanne@nexb.com, Andrew Morton <akpm@linux-foundation.org>, steve.capper@arm.com, punit.agrawal@arm.com, aneesh.kumar@linux.vnet.ibm.com, npiggin@gmail.com, Kees Cook <keescook@chromium.org>, bhsharma@redhat.com, riel@redhat.com, nitin.m.gupta@oracle.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, ross.zwisler@linux.intel.com, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-alpha@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-snps-arc@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Fri 23-03-18 20:55:49, Ilya Smith wrote:
> 
> > On 23 Mar 2018, at 15:48, Matthew Wilcox <willy@infradead.org> wrote:
> > 
> > On Thu, Mar 22, 2018 at 07:36:36PM +0300, Ilya Smith wrote:
> >> Current implementation doesn't randomize address returned by mmap.
> >> All the entropy ends with choosing mmap_base_addr at the process
> >> creation. After that mmap build very predictable layout of address
> >> space. It allows to bypass ASLR in many cases. This patch make
> >> randomization of address on any mmap call.
> > 
> > Why should this be done in the kernel rather than libc?  libc is perfectly
> > capable of specifying random numbers in the first argument of mmap.
> Well, there is following reasons:
> 1. It should be done in any libc implementation, what is not possible IMO;

Is this really so helpful?

> 2. User mode is not that layer which should be responsible for choosing
> random address or handling entropy;

Why?

> 3. Memory fragmentation is unpredictable in this case
> 
> Off course user mode could use random ‘hint’ address, but kernel may
> discard this address if it is occupied for example and allocate just before
> closest vma. So this solution doesn’t give that much security like 
> randomization address inside kernel.

The userspace can use the new MAP_FIXED_NOREPLACE to probe for the
address range atomically and chose a different range on failure.

-- 
Michal Hocko
SUSE Labs
