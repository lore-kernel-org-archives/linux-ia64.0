From: Tony Luck <tony.luck@gmail.com>
Date: Wed, 13 Feb 2013 00:32:16 +0000
Subject: Re: [PATCH V3] ia64/mm: fix a bad_page bug when crash kernel booting
Message-Id: <CA+8MBbK7ZSkk2tOfjbeKuyCJ1mBT5OeY3GHKLS2EVFwH_nXZYA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <51074786.5030007@huawei.com>
	<1359995565.7515.178.camel@mfleming-mobl1.ger.corp.intel.com>
	<51131248.3080203@huawei.com>
	<5113450C.1080109@huawei.com>
	<CA+8MBb+3_xWv1wMWv0+gwWm9exPCNTZWG3mXQnBsUbc5fJnuiA@mail.gmail.com>
	<20130212161912.6a9e9293.akpm@linux-foundation.org>
In-Reply-To: <20130212161912.6a9e9293.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Matt Fleming <matt.fleming@intel.com>, fenghua.yu@intel.com, Liujiang <jiang.liu@huawei.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, WuJianguo <wujianguo@huawei.com>

On Tue, Feb 12, 2013 at 4:19 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> But, umm, why am I sitting here trying to maintain an ia64 bugfix and
> handling bug reports from the ia64 maintainer?  Wanna swap?

That sounds like a plan.  I'll look out for a new version with the
missing #include
and less silly global variable names and try to take it before you
pull it into -mm

-Tony
