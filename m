From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Fri, 30 Jul 2004 22:55:04 +0000
Subject: Re: [BROKEN PATCH] kexec for ia64
Message-Id: <20040730155504.2a51b1fa.rddunlap@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
In-Reply-To: <200407261524.40804.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 26 Jul 2004 15:36:05 -0700 Jesse Barnes wrote:

| On Monday, July 26, 2004 3:24 pm, Jesse Barnes wrote:
| >   o userspace tools need ia64 support
| >   o need to deal with in-flight DMA (see FIXME in machine_kexec)
| 
| After looking at it a little more, I suppose device_shutdown() should 
| theoretically deal with this.
| 
| Also, it would be nice if there were a Documentation/kexec.txt or something in 
| the full patch that describes all the pieces and what the arch dependent 
| functions are responsible for.  Randy, do you have anything like that written 
| up somewhere that you could include in the next spin of the patch?

Nope, sorry, I don't have anything like that.

Eric, do you have anything like Jesse asked about (arch-dependent
requirements)?

--
~Randy
