From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 13 Nov 2003 16:43:37 +0000
Subject: RE: Machine check when executing ptc.ga
Message-Id: <marc-linux-ia64-106874240705584@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106874043202631@msgid-missing>
In-Reply-To: <marc-linux-ia64-106874043202631@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The failing instruction is:
> 
>        ptc.ga r32,r34;;
> 
> and r32 = a0000000 00000000, r34 = 00000000 00000040.

You are flushing 64k bytes at 0xa000000000000000.  A default
pagesize of 16k would mean that this range includes the
per-cpu area (at 0xa000000000000000 + 2*PAGE_SIZE on 2.4.20).
The per-cpu area is mapped by an entry pinned into the TLB
by DTR[1] ... so the ptc chokes beacause it can only flush
TLB cache entries.

-Tony
