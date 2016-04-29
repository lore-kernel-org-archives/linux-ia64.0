From: Pratyush Anand <panand@redhat.com>
Date: Fri, 29 Apr 2016 15:59:40 +0000
Subject: Re: [PATCH 10/12] kexec: arrange for paddr_vmcoreinfo_note() to return phys_addr_t
Message-Id: <CAHB_GurwYqPbccLU9UHppLxbBr4Cfs47myKAer-RJicT=T7uBw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
	<E1aviFP-0000je-5t@rmk-PC.arm.linux.org.uk>
	<CAHB_Gur-6oyEheN-Pom7OwivdvrQpCBaXvM1V2H0JPFRCFZthA@mail.gmail.com>
	<20160429151639.GC23726@leverpostej>
In-Reply-To: <20160429151639.GC23726@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Rutland <mark.rutland@arm.com>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, Jonathan Corbet <corbet@lwn.net>, Ian Campbell <ijc+devicetree@hellion.org.uk>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, Vivek Goyal <vgoyal@redhat.com>

On Fri, Apr 29, 2016 at 8:46 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Fri, Apr 29, 2016 at 08:36:43PM +0530, Pratyush Anand wrote:
>> > +       phys_addr_t vmcore_base = paddr_vmcoreinfo_note();
>> > +       return sprintf(buf, "%pa %x\n", &vmcore_base,
>>
>> Why do we pass &vmcore_base? Shouldn't it be vmcore_base?
>
> The %pa* printk format specifiers take the value by reference (as
> phys_addr_t and friends are not necessarily the same width as a
> pointer). Per Documentation/printk-formats.txt:
>
> Physical addresses types phys_addr_t:
>
>         %pa[p]  0x01234567 or 0x0123456789abcdef
>
>         For printing a phys_addr_t type (and its derivatives, such as
>         resource_size_t) which can vary based on build options, regardless of
>         the width of the CPU data path. Passed by reference.
>
> So the above prints the value of vmcore_base as expected.

Thanks a lot Mark for explaining :-)

Reviewed-by: Pratyush Anand <panand@redhat.com>
