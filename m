From: Grant Grundler <iod00d@hp.com>
Date: Thu, 17 Jun 2004 18:50:03 +0000
Subject: Re: sys_ioctl export
Message-Id: <20040617185003.GH7313@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
In-Reply-To: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 17, 2004 at 11:31:11AM -0700, Mark Haverkamp wrote:
> > Did you need to call sys_ioctl() directly from a module?
> 
> Yes, a 32 bit compatible ioctl function needs to call sys_ioctl once it
> has massaged the data, to execute its function. sys_ioctl isn't an arch
> specific function.  It isn't exported normally.  It looks like it is
> exported by 64 bit architectures only.

ia64 doesn't support a native 32-bit implementation like
parisc, mips, sparc, et al do. At least not yet. 
Adding that support will need to add those EXPORT_SYMBOLs.

I don't know how the current ia32 support works though.
Obviously not as a module...

grant
