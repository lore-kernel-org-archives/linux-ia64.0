From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 20 Dec 2005 16:54:46 +0000
Subject: Re: [Perfctr-devel] 2.6.15-rc5-git3 perfmon2 new code base + libpfm available
Message-Id: <20051220165446.GY2361@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051215104604.GA16937@frankl.hpl.hp.com> <43A1DE94.8050105@redhat.com> <20051215215921.GJ18331@frankl.hpl.hp.com> <43A1ECDF.9040200@nc.rr.com> <20051215231510.GC18796@frankl.hpl.hp.com> <43A82BAE.1010008@nc.rr.com>
In-Reply-To: <43A82BAE.1010008@nc.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: William Cohen <wcohen@nc.rr.com>
Cc: eranian@hpl.hp.com, William Cohen <wcohen@redhat.com>, perfctr-devel@lists.sourceforge.net, perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 20, 2005 at 11:05:02AM -0500, William Cohen wrote:
> Dec 20 10:29:47 trek kernel: Unable to handle kernel paging request at 
> virtual address 6b6b6ba7

mm/slab.c:#define POISON_FREE   0x6b    /* for use-after-free poisoning */

