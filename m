From: Tony Luck <tony.luck@gmail.com>
Date: Thu, 21 Feb 2013 18:21:46 +0000
Subject: Re: [PATCH V3] ia64/mm: fix a bad_page bug when crash kernel booting
Message-Id: <CA+8MBbJdOCh5Hh-K6wRDzACy-a4S1qV2S5zxwJk2MhAhZvxbqg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <51074786.5030007@huawei.com>
	<1359995565.7515.178.camel@mfleming-mobl1.ger.corp.intel.com>
	<51131248.3080203@huawei.com>
	<5113450C.1080109@huawei.com>
	<CA+8MBbKuBheEj9t8whJBc=S7NdxCF8MvuD2Ajm7suP=7JC01fg@mail.gmail.com>
	<51242908.2050308@huawei.com>
In-Reply-To: <51242908.2050308@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Matt Fleming <matt.fleming@intel.com>, fenghua.yu@intel.com, Liujiang <jiang.liu@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, WuJianguo <wujianguo@huawei.com>, linux-arch@vger.kernel.org

On Tue, Feb 19, 2013 at 5:38 PM, Xishi Qiu <qiuxishi@huawei.com> wrote:
> Seems like a good idea, should we modify "\linux\Documentation\kernel-parameters.txt"?

Perhaps in Documentation/kdump/kdump.txt (which the crashkernel entry
in kernel-parameters.txt
points at).  The ia64 section of kdump.txt notes that the start
address will be rounded up to
a GRANULE boundary, but doesn't talk about restrictions on the size.

I wonder if any other architectures have alignment restrictions on the
addresses in
"crashkernel" parameters? Does x86 like them to be 2MB aligned?

Second question is whether we should check and warn in parse_crashkernel_mem()?
I think the answer is "yes" (since the consequences of getting this
wrong don't show
up till much later, and the errors aren't all that obviously connected
back to the original
mistake).  Perhaps each architecture that cares could provide defines:

#define ARCH_CRASH_KERNEL_START_ALIGN (... arch value here ...)
#define ARCH_CRASH_KERNEL_SIZE_ALIGN (... arch value here ...)

[Suggestion provided mostly to provoke somebody to provide a more
elegant solution]

-Tony
