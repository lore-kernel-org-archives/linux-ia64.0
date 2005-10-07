From: James E Wilson <wilson@tuliptree.org>
Date: Fri, 07 Oct 2005 18:19:51 +0000
Subject: Re: PATCH: Fix 2.6 kernel for the new ia64 assembler
Message-Id: <1128709191.375.5.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051007180119.GA11645@lucon.org>
In-Reply-To: <20051007180119.GA11645@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2005-10-07 at 11:01, H. J. Lu wrote:
> The new ia64 assembler uses slot 1 for the offset of a long (2-slot)
> instruction and the old assembler uses slot 2. The 2.6 kernel assumes
> slot 2 and won't boot when the new assembler is used:

Specifically, this is in reference to tags occurring immediately before
a long instruction.

Given something like
	.text
	nop
[L1:]
	movl
The value of L1 should be .text+1 but it was incorrectly .text+2 until
about 2 weeks ago.  Unfortunately, there is code in the kernel that
relies on the incorrect value, and needs to be fixed.  H.J.'s patch
fixes this.


