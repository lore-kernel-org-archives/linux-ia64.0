From: Tony Luck <tony.luck@gmail.com>
Date: Wed, 16 Jul 2014 23:20:00 +0000
Subject: Re: [PATCH 2/2] ia64: Remove Linux/x86 domain support
Message-Id: <CA+8MBbKA5UppTjLP6JYAeLMAyeUPBfF73j91xDCfoF_Vewy5=A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1405263538-27589-1-git-send-email-richard@nod.at>
	<1405263538-27589-3-git-send-email-richard@nod.at>
In-Reply-To: <1405263538-27589-3-git-send-email-richard@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Richard Weinberger <richard@nod.at>
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sun, Jul 13, 2014 at 7:58 AM, Richard Weinberger <richard@nod.at> wrote:

Did you read the comment?

> -/*
> - * Even when CONFIG_IA32_SUPPORT is not enabled it is
> - * useful to have the Linux/x86 domain registered to
> - * avoid an attempted module load when emulators call
> - * personality(PER_LINUX32). This saves several milliseconds
> - * on each such call.
> - */

I don't know if there are still people using ia32el to run x86 binaries
on ia64 ... but if there are, they may be sad at the extra delays.

-Tony
