From: "David S. Miller" <davem@davemloft.net>
Date: Wed, 20 Oct 2004 23:41:44 +0000
Subject: Re: [discuss] Re: [PATCH] Add key management syscalls to non-i386
Message-Id: <20041020164144.3457eafe.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <3506.1098283455@redhat.com>
	<20041020150149.7be06d6d.davem@davemloft.net>
	<20041020225625.GD995@wotan.suse.de>
	<20041020160450.0914270b.davem@davemloft.net>
	<20041020232509.GF995@wotan.suse.de>
In-Reply-To: <20041020232509.GF995@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: ak@suse.de, dhowells@redhat.com, torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org, discuss@x86-64.org, sparclinux@vger.kernel.org, linuxppc64-dev@ozlabs.org, linux-m68k@vger.kernel.org, linux-sh@m17n.org, linux-arm-kernel@lists.arm.linux.org.uk, parisc-linux@parisc-linux.org, linux-ia64@vger.kernel.org, linux-390@vm.marist.edu, linux-mips@linux-mips.org

On Thu, 21 Oct 2004 01:25:09 +0200
Andi Kleen <ak@suse.de> wrote:

> IMHO breaking the build unnecessarily is extremly bad because
> it will prevent all testing. And would you really want to hold
> up the whole linux testing machinery just for some obscure 
> system call? IMHO not a good tradeoff.

Then change the unistd.h cookie from "#error" to a "#warning".  It
accomplishes both of our goals.
