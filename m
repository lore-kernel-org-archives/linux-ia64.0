From: Andrew Morton <akpm@linux-foundation.org>
Date: Sat, 22 Aug 2009 00:24:07 +0000
Subject: Re: [Patch 5/8] ia64: implement crashkernel=auto
Message-Id: <20090821172407.d3a5cd2b.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090821065637.4855.32234.sendpatchset@localhost.localdomain>
	<20090821065729.4855.47860.sendpatchset@localhost.localdomain>
In-Reply-To: <20090821065729.4855.47860.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, nhorman@redhat.com, ebiederm@xmission.com, andi@firstfloor.org, mingo@elte.hu, amwang@redhat.com, bernhard.walle@gmx.de, fenghua.yu@intel.com, kamezawa.hiroyu@jp.fujitsu.com, avorontsov@ru.mvista.com

On Fri, 21 Aug 2009 02:55:04 -0400
Amerigo Wang <amwang@redhat.com> wrote:

> +#ifdef CONFIG_KEXEC_AUTO_RESERVE
> +#define ARCH_HAS_DEFAULT_CRASH_SIZE
> +static inline
> +unsigned long long arch_default_crash_size(unsigned long long total_size)
> +{
> +	if (total_size >= 4ULL<<30 && total_size < 12ULL<<30)
> +		return 1ULL<<28;
> +	else if (total_size >= 12ULL<<30 && total_size < 128ULL<<30)
> +		return 1ULL<<29;
> +	else if (total_size >= 128ULL<<30 && total_size < 256ULL<<30)
> +		return 3ULL<<28;
> +	else if (total_size >= 256ULL<<30 && total_size < 378ULL<<30)
> +		return 1ULL<<30;
> +	else if (total_size >= 318ULL<<30 && total_size < 512ULL<<30)
> +		return 3ULL<<29;
> +	else if (total_size >= 512ULL<<30 && total_size < 768ULL<<30)
> +		return 2ULL<<30;
> +	else if (total_size >= 768ULL<<30)
> +		return 3ULL<<30;
> +}
> +#include <asm-generic/kexec.h>
> +#endif

a) Why on earth is this inlined?

b) Please consider making arch_default_crash_size() a __weak
   function.  You'll probably find the result to be pleasing.

c) If we can't use __weak then please don't add
   ARCH_HAS_DEFAULT_CRASH_SIZE.  Instead do this trick:


	#ifndef arch_default_crash_size
	static inline unsigned long long arch_default_crash_size(unsigned long long total_size)
	{
		...
	}
	#define arch_default_crash_size arch_default_crash_size
	#endif

	because i) it's good to standardise on something and ii) one less
	symbol gets added to the kernel.

d) why is asm-generic/kexec.h only included in asm/kexec.h if
   CONFIG_KEXEC_AUTO_RESERVE happened to be defined?  That makes no
   sense - there may be a multitude of reasons why asm/kexec.h wants
   to include asm-generic/kexec.h.

