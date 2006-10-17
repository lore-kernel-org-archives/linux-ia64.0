From: Jes Sorensen <jes@sgi.com>
Date: Tue, 17 Oct 2006 08:49:35 +0000
Subject: Re: Mspec driver and non-SN platforms?
Message-Id: <yq0slhn9vj4.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <877iyz4qbj.peterc%peterc@gelato.unsw.edu.au>
In-Reply-To: <877iyz4qbj.peterc%peterc@gelato.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peterc@gelato.unsw.edu.au> writes:

Peter> Hi, If you try to enable mspec when compiling for other than
Peter> SN, you get undefined references to uncached_free_page,
Peter> per_cpu__sn_hub_info, physical_node_map, and bte_copy.

Peter> Maybe the attached patch is needed... which disables fetchop
Peter> for other than Altix or generic kernels.  If and when the
Peter> facility becomes available on other platforms, it's probably
Peter> going to need a new driver (and new CONFIG option) anyway.

I don't like this approach, the driver should work for non SN hardware
in uncached and cached mode, so lets try and fix it correctly instead.

Cheers,
Jes
