From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 24 Oct 2014 12:36:10 +0000
Subject: Re: [PATCH v9 09/12] x86, mpx: decode MPX instruction to get bound violation information
Message-Id: <alpine.DEB.2.11.1410241408360.5308@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-10-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1413088915-13428-10-git-send-email-qiaowei.ren@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Sun, 12 Oct 2014, Qiaowei Ren wrote:

> This patch sets bound violation fields of siginfo struct in #BR
> exception handler by decoding the user instruction and constructing
> the faulting pointer.
> 
> This patch does't use the generic decoder, and implements a limited
> special-purpose decoder to decode MPX instructions, simply because the
> generic decoder is very heavyweight not just in terms of performance
> but in terms of interface -- because it has to.

My question still stands why using the existing decoder is an
issue. Performance is a complete non issue in case of a bounds
violation and the interface argument is just silly, really.
 
Thanks,

	tglx
