From: david mosberger <dmosberger@gmail.com>
Date: Tue, 12 Jul 2005 21:39:20 +0000
Subject: Re: [PATCH] enable to read region 5 from /dev/kmem
Message-Id: <ed5aea430507121439364f9d0@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42C501CD.4010907@jp.fujitsu.com>
In-Reply-To: <42C501CD.4010907@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 7/12/05, Luck, Tony <tony.luck@intel.com> wrote:

> It comes down to what the real semantics of /dev/kmem are supposed
> to be.

That is certainly true.  I thought we had settled that pages with the
WB attribute would _only_ be accessible in a cacheable fashion and
pages without the WB attribute would _only_ be accessible uncached.

 --david
