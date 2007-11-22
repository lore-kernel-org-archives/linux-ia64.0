From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 22 Nov 2007 03:32:49 +0000
Subject: Re: [PATCH RFC][try 2] IA64 signal : remove redundant code in setup_sigcontext()
Message-Id: <20071122033249.GM12494@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4744F46B.6050004@cn.fujitsu.com>
In-Reply-To: <4744F46B.6050004@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Shi Weihua <shiwh@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Thu, Nov 22, 2007 at 11:15:55AM +0800, Shi Weihua wrote:
> This patch removes some redundant code in the function setup_sigcontext().
> 
> The registers ar.ccv,b7,r14,ar.csd,ar.ssd,r2-r3 and r16-r31 are not restored 
> in restore_sigcontext() when (flags & IA64_SC_FLAG_IN_SYSCALL) is true. 
> So we don't need to zero those variables in setup_sigcontext().

Erm, couldn't those registers contain information the process shouldn't
see?

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
