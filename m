From: Grant Grundler <iod00d@hp.com>
Date: Wed, 04 Aug 2004 23:33:35 +0000
Subject: Re: [BROKEN PATCH] kexec for ia64
Message-Id: <20040804233335.GD548@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com> <200407261536.05133.jbarnes@engr.sgi.com> <20040730155504.2a51b1fa.rddunlap@osdl.org> <m18ycvhx1j.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m18ycvhx1j.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, Jesse Barnes <jbarnes@engr.sgi.com>, linux-ia64@vger.kernel.org, fastboot@osdl.org, linux-kernel@vger.kernel.org

On Wed, Aug 04, 2004 at 07:07:04AM -0600, Eric W. Biederman wrote:
> Initially that patch
> was targeted for a kernel without device_shutdown(), so I was
> likely considering the old trick of running through all of the PCI
> devices and disabling their bus master bit.

Blindly disabling all PCI bus master bits will also kill VGA/serial
console and any USB keyboard attached to the system.

I'll comment more on the "DMA is a Red Herring" when I can read
more what it is about.

grant
