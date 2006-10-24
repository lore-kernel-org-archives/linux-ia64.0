From: Horms <horms@verge.net.au>
Date: Tue, 24 Oct 2006 00:46:50 +0000
Subject: Re: [patch 0/5] Physical mode SAL calls
Message-Id: <20061024004650.GA25701@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061023084840.730815639@tabatha.lab.ultramonkey.org>
In-Reply-To: <20061023084840.730815639@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 23, 2006 at 10:15:58AM -0500, Jack Steiner wrote:
> SN systems support additional vendor-specific SAL calls. Some
> of these pass kernel addresses to SAL for input or output buffers.
> At a minimum, these buffer addresses need to be converted to 
> physical addresses if SAL is run in physical mode.
> 
> In addition, I think there may be additional problems with our SAL
> if we try to run only in physical mode. I'll take a look.....

Thanks. These patches do seem to work fairly well on my Tiger 2.
But its obviously a fairly tricky area.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

