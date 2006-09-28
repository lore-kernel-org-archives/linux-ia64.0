From: Horms <horms@verge.net.au>
Date: Thu, 28 Sep 2006 01:27:33 +0000
Subject: Re: [Xen-ia64-devel] Re: ia64 kexec: xen -> linux
Message-Id: <20060928012731.GA13465@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200609271152.12393.Tristan.Gingold@bull.net>
In-Reply-To: <200609271152.12393.Tristan.Gingold@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 27, 2006 at 11:52:12AM +0200, Tristan Gingold wrote:
> 
> Linux and xen call efi in real mode if set_virtual_address_map fails.
> You may add an option in both xen and linux to force calling efi in real mode.
> This should be really simple and you will be able to make progress.

Great, I will test this out and see how it goes.

> The only possible drawback is performance.

What kind of performance issues would you expect?

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

