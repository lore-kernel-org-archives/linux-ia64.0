From: Keith Owens <kaos@sgi.com>
Date: Thu, 29 Apr 2004 04:08:31 +0000
Subject: 2.6.5 unwind problem with rp <- r0
Message-Id: <4885.1083211711@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Unwinding through a kernel thread, we hit kernel_thread_helper which is
called from start_kernel_thread with unwind data

        .save rp, r0                            // this is the end of the call-chain

The kernel unwinder does not handle this correctly, it spits
  unwind.pt_regs_off: bad scratch reg r0
and keeps unwinding, generating garbage.

