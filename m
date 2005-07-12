From: david mosberger <dmosberger@gmail.com>
Date: Tue, 12 Jul 2005 18:23:41 +0000
Subject: Re: [PATCH] enable to read region 5 from /dev/kmem
Message-Id: <ed5aea43050712112318aa64a2@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42C501CD.4010907@jp.fujitsu.com>
In-Reply-To: <42C501CD.4010907@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 7/12/05, Luck, Tony <tony.luck@intel.com> wrote:
> This is better.  But allowing access to region 6 through
> /dev/kmem will open up a whole new set of problems.  If the
> user does an uncacheable read through region 6 from a memory
> address that is mapped cacheably in region 7, then the
> processor may machine check [SDM 4.4.1, page 2:64, last
> paragraph: "It is recommended that the processor report a
> Machine Check abort if the following memory attribute aliasing
> is detected: * cache-hit on an uncacheable page"]
> 
> So I think we should disallow access to region 6.

/dev/[k]mem should use the EFI memory attributes to determine
accessibility.  This is being done to some degree already (well, I
didn't check the current code, but it's supposed to be there).

  --david
