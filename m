From: Grant Grundler <iod00d@hp.com>
Date: Mon, 17 May 2004 15:45:59 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <20040517154559.GA23312@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 17, 2004 at 10:38:49AM +0200, Matthias Fouquet-Lapar wrote:
> I think I'm not quite sure why you need hotplug to balance CPUs between
> partitons. (You are not moving physical components for this, right ?)

It can look like it. Eg moving a "cell" on a superdome from
one hard partition to another completely dissassociates the 
"cell" from the previous partition as if it had been physically
removed.

grant
