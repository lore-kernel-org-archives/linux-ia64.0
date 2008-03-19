From: David Miller <davem@davemloft.net>
Date: Wed, 19 Mar 2008 21:30:37 +0000
Subject: Re: [PATCH 5/8] sparc64 ptrace: forced_successful_syscall_return()
Message-Id: <20080319.143037.180042261.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080319211714.8B14226F995@magilla.localdomain>
	<20080319212001.2DB8526F995@magilla.localdomain>
In-Reply-To: <20080319212001.2DB8526F995@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: roland@redhat.com
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, sparclinux@vger.kernel.org, paulus@samba.org, linuxppc-dev@ozlabs.org, rth@twiddle.net, tony.luck@intel.com, linux-ia64@vger.kernel.org

From: Roland McGrath <roland@redhat.com>
Date: Wed, 19 Mar 2008 14:20:01 -0700 (PDT)

> Define the forced_successful_syscall_return() macro to
> pair with our force_successful_syscall_return() definition.
> 
> Signed-off-by: Roland McGrath <roland@redhat.com>

Acked-by: David S. Miller <davem@davemloft.net>
