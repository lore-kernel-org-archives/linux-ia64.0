From: Pratyush Anand <panand@redhat.com>
Date: Fri, 29 Apr 2016 14:56:03 +0000
Subject: Re: [PATCH 06/12] ARM: kexec: advertise location of bootable RAM
Message-Id: <CAHB_GurHc1aVfzJATpNW5yf5s5KkF=t5s09FbWq3+9+ZX39KUg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
	<E1aviF4-0000jG-MO@rmk-PC.arm.linux.org.uk>
In-Reply-To: <E1aviF4-0000jG-MO@rmk-PC.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, Jonathan Corbet <corbet@lwn.net>, Ian Campbell <ijc+devicetree@hellion.org.uk>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, Vivek Goyal <vgoyal@redhat.com>

Hi Russell,

On Thu, Apr 28, 2016 at 2:58 PM, Russell King
<rmk+kernel@arm.linux.org.uk> wrote:
> Advertise the location of bootable RAM to kexec-tools.  kexec needs to
> know where it can place the kernel in RAM, and so be executable when
> the system needs to jump into it.
>
> Advertise these areas in /proc/iomem with a "System RAM (boot alias)"
> tag.
>
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Can you please also share git tree path of corresponding kexec-tools changes?

Could it be a better idea (if things in user space become simpler)
that in stead of patch 5 and 6, we pass arch_phys_to_idmap_offset to
user space, and then user space manipulates existing "Crash kernel"
and "System RAM" resources.

~Pratyush
