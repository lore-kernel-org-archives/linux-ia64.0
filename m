From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 29 Feb 2020 20:44:29 +0000
Subject: Re: [PATCH v3 2/7] mm/memory_hotplug: Rename mhp_restrictions to mhp_params
Message-Id: <CAPcyv4hLvciwxSnsQRye9SuB-sy9fm+_6CwZSuHifkmbWQs-+g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200221182503.28317-1-logang@deltatee.com>
 <20200221182503.28317-3-logang@deltatee.com>
In-Reply-To: <20200221182503.28317-3-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-ia64@vger.kernel.org, Linux-sh <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, platform-driver-x86@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Will Deacon <will@kernel.org>, Christoph Hellwig <hch@lst.de>, linux-s390 <linux-s390@vger.kernel.org>, David Hildenbrand <david@redhat.com>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Eric Badger <ebadger@gigaio.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Fri, Feb 21, 2020 at 10:25 AM Logan Gunthorpe <logang@deltatee.com> wrote:
>
> The mhp_restrictions struct really doesn't specify anything resembling
> a restriction anymore so rename it to be mhp_params as it is a list
> of extended parameters.
>
> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>

Tests ok, and looks good to me:

Reviewed-by: Dan Williams <dan.j.williams@intel.com>
