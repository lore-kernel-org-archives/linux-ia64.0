From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 15 Jan 2009 12:21:56 +0000
Subject: Re: crash: IP: [<ffffffff80478092>] __bitmap_intersects+0x48/0x73
Message-Id: <20090115122156.GA20349@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <496BF6D5.9030403@sgi.com> <20090113130048.GB31147@elte.hu> <496CAF5A.3010304@sgi.com> <496D0F46.2010907@sgi.com> <496D2172.6030608@sgi.com> <20090114165431.GA18826@elte.hu> <20090114165524.GA21742@elte.hu> <20090114175126.GA21078@elte.hu> <496E78BA.5040609@sgi.com> <20090115101617.GH5833@elte.hu>
In-Reply-To: <20090115101617.GH5833@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Mike Travis <travis@sgi.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Yinghai Lu <yinghai@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tony Luck <tony.luck@intel.com>, IA64 <linux-ia64@vger.kernel.org>, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, linux-am33-list@redhat.com, "David S. Miller" <davem@davemloft.net>, SPARC <sparclinux@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>


FYI, there's new warnings due to cpumask changes:

arch/x86/kernel/cpu/intel_cacheinfo.c: In function ‘show_cache_disable’:
arch/x86/kernel/cpu/intel_cacheinfo.c:710: warning: unused variable ‘mask’
arch/x86/kernel/cpu/intel_cacheinfo.c: In function ‘store_cache_disable’:
arch/x86/kernel/cpu/intel_cacheinfo.c:745: warning: unused variable ‘mask’

on 32-bit defconfig.

	Ingo
