From: Joe Perches <joe@perches.com>
Date: Mon, 04 Jan 2016 16:47:53 +0000
Subject: Re: [PATCH 3/3] checkpatch: add virt barriers
Message-Id: <1451926073.4334.90.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451907395-15978-1-git-send-email-mst@redhat.com>
	 <1451907395-15978-4-git-send-email-mst@redhat.com>
In-Reply-To: <1451907395-15978-4-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Cc: "Cc : Andy Whitcroft" <apw@canonical.com>, Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@kernel.org>, Tony Lindgren <tony@atomide>

On Mon, 2016-01-04 at 13:37 +0200, Michael S. Tsirkin wrote:
> Add virt_ barriers to list of barriers to check for
> presence of a comment.

Are these virt_ barriers used anywhere?

I see some virtio_ barrier like uses.

