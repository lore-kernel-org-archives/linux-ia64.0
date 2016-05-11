From: Dave Young <dyoung@redhat.com>
Date: Wed, 11 May 2016 08:29:23 +0000
Subject: Re: [PATCH 00/12] Fixing TI Keystone2 kexec
Message-Id: <20160511082923.GC8995@dhcp-128-65.nay.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
In-Reply-To: <20160428092644.GX19428@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, Jonathan Corbet <corbet@lwn.net>, Ian Campbell <ijc+devicetree@hellion.org.uk>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, Vivek Goyal <vgoyal@redhat.com>

Hi, Russell

On 04/28/16 at 10:26am, Russell King - ARM Linux wrote:
> These changes are required for TI Keystone2 kexec to be functional.  TI
> Keystone2 has the run-time view of physical memory above 4GiB, but with
> a boot time alias below 4GiB which can only be used during the early
> boot.
> 
> This means we need to translate run-time physical addresses (which the
> kernel uses) to boot-time physical addresses, which, having discussed
> with Eric, is what the kexec tools and kexec kernel API requires.
> 
> We publish a special set of boot time resources in /proc/iomem, which
> the (modified) kexec tools look for in preference to the normal resources.
> Hence, if these are found, the kexec tools make use of these resources,
> and thus kexec tools use the boot-time view of physical memory.

I think getting memory ranges from device tree will be better than
adding more stuff to /proc/iomem. Geoff's arm64 kexec patches is using dtb
you can refer to the patchset.

Thanks
Dave
