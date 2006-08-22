From: Horms <horms@verge.net.au>
Date: Tue, 22 Aug 2006 11:10:59 +0000
Subject: Re: Increase default nodes shift to 10
Message-Id: <20060822111059.BC85734055@koto.vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0608211908270.21433@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608211908270.21433@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, 21 Aug 2006 19:11:52 -0700 (PDT), Christoph Lameter wrote:
> We have systems with 1024 nodes and 1024 processors. Could we set
> the default nodes shift to 10?

It seems curious to set the default to the top of the available range,
persubably there aren't many of these systems around. Is there a
penalty for smaller systems?

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

