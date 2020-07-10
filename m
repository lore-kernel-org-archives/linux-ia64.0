From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 10 Jul 2020 14:00:15 +0000
Subject: Re: [PATCH v4 0/2] Fix and enable pmem as RAM device on arm64
Message-Id: <CAPcyv4izHex9W0m3voSXM5J69gFWhHj_a-XsmJ4HF01Uh4jp6w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200710031619.18762-1-justin.he@arm.com>
In-Reply-To: <20200710031619.18762-1-justin.he@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jia He <justin.he@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, David Hildenbrand <david@redhat.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Chuhong Yuan <hslester96@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Masahiro Yamada <masahiroy@kernel.org>, Michal Hocko <mhocko@suse.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linux-sh <linux-sh@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, , Jonathan Cameron <Jonathan.Cameron@huawei.com>, Kaly Xin <Kaly.Xin@arm.com>

On Thu, Jul 9, 2020 at 8:17 PM Jia He <justin.he@arm.com> wrote:
>
> This fixies a few issues when I tried to enable pmem as RAM device on arm64.
>
> To use memory_add_physaddr_to_nid as a fallback nid, it would be better
> implement a general version (__weak) in mm/memory_hotplug. After that, arm64/
> sh/s390 can simply use the general version, and PowerPC/ia64/x86 will use
> arch specific version.
>
> Tested on ThunderX2 host/qemu "-M virt" guest with a nvdimm device. The
> memblocks from the dax pmem device can be either hot-added or hot-removed
> on arm64 guest. Also passed the compilation test on x86.
>
> Changes:
> v4: - remove "device-dax: use fallback nid when numa_node is invalid", wait
>       for Dan Williams' phys_addr_to_target_node() patch

FWIW, I put these patches through a 0-day run overnight and will be
posting them today.
