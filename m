From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 09 Jul 2013 20:43:17 +0000
Subject: Re: ia64: dmi.h: Make dmi_alloc use kzalloc
Message-Id: <CA+8MBbJmm1ehU1dKUM2YYy-gBG5n6hGt6-vjyvE=9COa+ZSt=A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1373384438.4391.6.camel@chaos.site>
	<1373384574.4391.9.camel@chaos.site>
	<1373386794.14604.14.camel@joe-AO722>
	<1373389983.14604.18.camel@joe-AO722>
In-Reply-To: <1373389983.14604.18.camel@joe-AO722>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Jean Delvare <jdelvare@suse.de>, linux-kernel@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>

On Tue, Jul 9, 2013 at 10:13 AM, Joe Perches <joe@perches.com> wrote:
> x86/ia64 have a slight mismatch in dmi_alloc as
> x86 does a memset(0), and ia64 just does kmalloc.
>
> Make the ia64 dmi_alloc match the x86 style.
>
> Signed-off-by: Joe Perches <joe@perches.com>

Applied. Thanks Joe.

-Tony
