From: Mark Goodwin <markgw@sgi.com>
Date: Tue, 09 Nov 2004 20:34:17 +0000
Subject: Re: Externalize SLIT table
Message-Id: <Pine.LNX.4.61.0411100722070.14545@woolami.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041103205655.GA5084@sgi.com>  <20041104.105908.18574694.t-kochi@bq.jp.nec.com>
  <20041104141337.GA18445@sgi.com>  <200411041631.42627.efocht@hpce.nec.com>
 <1100029381.3980.12.camel@arrakis>
In-Reply-To: <1100029381.3980.12.camel@arrakis>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Erich Focht <efocht@hpce.nec.com>, Jack Steiner <steiner@sgi.com>, Takayoshi Kochi <t-kochi@bq.jp.nec.com>, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>


On Tue, 9 Nov 2004, Matthew Dobson wrote:
> ...
> I don't think we should export the *exact same* node distance information
> through the CPUs, though.

We should still export cpu distances though because the distance between
cpus on the same node may not be equal. e.g. consider a node with multiple
cpu sockets, each socket with a hyperthreaded (or dual core) cpu.

Once again however, it depends on the definition of distance. For nodes,
we've established it's the ACPI SLIT (relative distance to memory). For
cpus, should it be distance to memory? Distance to cache? Registers? Or
what?

-- Mark
