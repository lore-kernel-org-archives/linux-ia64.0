From: Christopher Wedgwood <cw@sgi.com>
Date: Tue, 22 Jul 2003 04:43:35 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105884902708537@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jul 21, 2003 at 09:08:28PM -0600, Bjorn Helgaas wrote:

> Yeah, I agree.  What about doing it for 2.5/2.6 first?

If David is willing I'll take a stab...  the code is pretty horrendous
in places in the way it runs on large NUMA machines from memory
(printk efi_memmap_walk and watch the run).

I'll make some notes later this week for people to tear apart.

For 2.4.x though I'll move the code into the driver as I have pretty
limited cycles.



Thanks,
  --cw
