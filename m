From: Grant Grundler <iod00d@hp.com>
Date: Thu, 17 Jun 2004 18:20:46 +0000
Subject: Re: sys_ioctl export
Message-Id: <20040617182046.GE7313@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
In-Reply-To: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 17, 2004 at 10:52:27AM -0700, Mark Haverkamp wrote:
> The ia64 arch doesn't export sys_ioctl like some other 64 bit
> architectures like ppc64, sparc64 and x86_64.  Was this intentional?

Yes. C files export their own symbols now. This is "new" to 2.6.
"fgrep EXPORT_SYMBOL arch/ia64/kernel/*.c" for examples.

Did you need to call sys_ioctl() directly from a module?

grant
