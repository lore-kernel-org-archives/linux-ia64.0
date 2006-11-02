From: Horms <horms@verge.net.au>
Date: Thu, 02 Nov 2006 08:24:25 +0000
Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <20061102082424.GA18475@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 02, 2006 at 10:13:12AM +0800, Zou, Nanhai wrote:
> Hi Neil,
> 	Does the attached patch fix the issue?

I gave your patch a quick test. It does seem to make the problem go
away, but it does not seem to be correct. It gives

early_node_map[1] active PFN ranges
    0:        0 ->    32768
(end of list)

But it really should be 16384 -> 32768

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

