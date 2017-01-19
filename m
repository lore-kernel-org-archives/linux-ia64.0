From: Greg KH <gregkh@linuxfoundation.org>
Date: Thu, 19 Jan 2017 11:02:21 +0000
Subject: Re: [PATCH v4 2/6] tools: add init.h for tools
Message-Id: <20170119110221.GB28024@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170109150249.11667-1-mcgrof@kernel.org>
 <20170115211215.17216-1-mcgrof@kernel.org>
 <20170115211215.17216-3-mcgrof@kernel.org>
In-Reply-To: <20170115211215.17216-3-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: gnomes@lxorguk.ukuu.org.uk, dalias@libc.org, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, heiko.carstens@de.ibm.com, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, mpe@ellerman.id.au, hpa@zytor.com, masami.hiramatsu.pt@hitachi.com, wangnan0@huawei.com, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, sparclinux@vger.kernel.org, xen-devel@lists.xensource.com, linux@arm.linux.org.uk, linux-sh@vger.kernel.org, will.deacon@arm.com, korea.drzix@gmail.com, x86@kernel.org, anil.s.keshavamurthy@intel.com, fontana@sharpeleven.org, mingo@redhat.com, dsahern@gmail.com, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, bp@suse.de, linux@roeck-us.net, david.vrabel@citrix.com, linux-xtensa@linux

On Sun, Jan 15, 2017 at 01:12:11PM -0800, Luis R. Rodriguez wrote:
> Start off with just __ref -- we enalbe you to override, if you do
> that then you can define your own.

I have no idea what this means, do you?

> The way you'd use this, if you
> do override, is define your own __ref and then use include_next.

Huh?

Again, please be more specific or clear or something, I have no idea
again what this patch is for.

thanks,

greg k-h
