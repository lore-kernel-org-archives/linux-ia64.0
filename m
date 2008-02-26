From: Shaohua Li <shaohua.li@intel.com>
Date: Tue, 26 Feb 2008 23:47:27 +0000
Subject: Re: [patch 3/3] remove duplicate code for register access
Message-Id: <1204069647.6836.0.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1203928727.3841.21.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1203928727.3841.21.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Tue, 2008-02-26 at 12:07 +0100, Petr Tesarik wrote:
> On Mon, 2008-02-25 at 16:38 +0800, Shaohua Li wrote:
> > We have duplicate code to access registers (access_uarea and regset
> > way). They just have different layout, so remove duplicate code.
> 
> This is incremental with my convert-to-arch-ptrace patchset, right?
Yes, I mentioned this in first patch too.

Thanks,
Shaohua

