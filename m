From: Chris Mason <mason@suse.com>
Date: Thu, 08 May 2003 16:42:27 +0000
Subject: RE: [Linux-ia64] High fpu register corruption
Message-Id: <marc-linux-ia64-105590723705683@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705679@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705679@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2003-05-08 at 12:33, Mallick, Asit K wrote:
> Andreas,
> 
> The high FP save and restore in the context switch makes the
> assumption that user will not be modifying the psr.mfh and it will be
> only updated by the hardware. Without this assumption we can not
> optimize the FP save/restore for SMP systems (this patch will not
> cover all cases). If application wants the current high fpu state to
> be preserved then it should will not be able to modify the psr.mfh.
> 
> What kind of applications are trying to modify the mfh?

The ia64 ssl source has hand optimized asm that clears mfh, but that
doesn't really matter.  What matters is that any application can do it,
so it has security implications.

-chris



