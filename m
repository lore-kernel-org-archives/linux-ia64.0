From: Pratyush Anand <panand@redhat.com>
Date: Fri, 29 Apr 2016 15:26:29 +0000
Subject: Re: [PATCH 11/12] kexec: allow architectures to override boot mapping
Message-Id: <CAHB_GuoPDxqKbbfGHW8UEiuCxdMeEVBCMJpouaO--dbLomkzrQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
	<E1aviFU-0000jk-9q@rmk-PC.arm.linux.org.uk>
In-Reply-To: <E1aviFU-0000jk-9q@rmk-PC.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, Jonathan Corbet <corbet@lwn.net>, Ian Campbell <ijc+devicetree@hellion.org.uk>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, Vivek Goyal <vgoyal@redhat.com>

On Thu, Apr 28, 2016 at 2:58 PM, Russell King
<rmk+kernel@arm.linux.org.uk> wrote:
> kexec physical addresses are the boot-time view of the system.  For
> certain ARM systems (such as Keystone 2), the boot view of the system
> does not match the kernel's view of the system: the boot view uses a
> special alias in the lower 4GB of the physical address space.
>
> To cater for these kinds of setups, we need to translate between the
> boot view physical addresses and the normal kernel view physical
> addresses.  This patch extracts the current transation points into
> linux/kexec.h, and allows an architecture to override the functions.
>
> Due to the translations required, we unfortunately end up with six
> translation functions, which are reduced down to four that the
> architecture can override.
>
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

I must be missing something when I am thinking that, had we passed
arch_phys_to_idmap_offset to user space, this patch would not have
been needed, and things would have been more simpler. Please help me
to understand why passing arch_phys_to_idmap_offset to user space
would not be a good idea.

~Pratyush
