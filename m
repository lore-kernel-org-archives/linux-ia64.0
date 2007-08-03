From: "Tony Luck" <tony.luck@intel.com>
Date: Fri, 03 Aug 2007 03:22:05 +0000
Subject: Re: ia64 mmu_gather question
Message-Id: <12c511ca0708022022v1d700b12t9146e28e270cd4d0@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186026055.5495.585.camel@localhost.localdomain>
In-Reply-To: <1186026055.5495.585.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Yup, I know. Your TLB miss rate gets lower as you fault in the page
> table pages, though it's still higher than a full tree walker. How big
> is the TLB btw ?

# of TLB entries is model specific ... most Itanium cpus so far have been around
128 entries give or take a few.

-Tony
