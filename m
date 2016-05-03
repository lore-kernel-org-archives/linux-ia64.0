From: Pratyush Anand <panand@redhat.com>
Date: Tue, 03 May 2016 05:53:36 +0000
Subject: Re: [PATCH 10/12] kexec: arrange for paddr_vmcoreinfo_note() to return phys_addr_t
Message-Id: <20160503055329.GA13045@dhcppc6.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
 <E1aviFP-0000je-5t@rmk-PC.arm.linux.org.uk>
 <CAHB_Gur-6oyEheN-Pom7OwivdvrQpCBaXvM1V2H0JPFRCFZthA@mail.gmail.com>
 <20160429151639.GC23726@leverpostej>
 <CAHB_GurwYqPbccLU9UHppLxbBr4Cfs47myKAer-RJicT=T7uBw@mail.gmail.com>
 <20160503042441.GA2518@x1.redhat.com>
In-Reply-To: <20160503042441.GA2518@x1.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baoquan He <bhe@redhat.com>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>, Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Ian Campbell <ijc+devicetree@hellion.org.uk>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, linux-arm-kernel@lists.infradead.org

Hi Baoquan,

On 03/05/2016:12:24:41 PM, Baoquan He wrote:
> Hi Pratyush,
> 
> Could you please help tell why arm PAE kernel can be put above 4G?

PAE system can have physical addresses above 4G. So, if a CPU is supporting the
LPAE page table format then we should be able to access physical addresses
beyond 4G.

> Since the change is related to common code, I am curious about how
> it's so different with other ARCHs.

paddr_vmcoreinfo_note() returns a physical address, so returning phys_addr_t
seems most appropriate. So, kernel variable may land into above 4G locations,
even with the platform in other architecture (with PAE support), if start of RAM
is located very high,

So, in my opinion it would be safer to have these changes for other ARCHs as
well.

~Pratyush
