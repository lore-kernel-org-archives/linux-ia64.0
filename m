From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 07 Feb 2005 16:51:46 +0000
Subject: Re: [PATCH 2.6.11-rc2 0/3] altix: AGP bridge support for tioca chip
Message-Id: <200502070851.47002.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050204213158.16671.87679.94380@attica.americas.sgi.com>
In-Reply-To: <20050204213158.16671.87679.94380@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, February 7, 2005 2:07 am, Christoph Hellwig wrote:
> Wouldn't it be better to allow pluggable IOMMUs at the ia64 architecture
> level, replacing the machvecs?
>
> zx1 already has a switch to use swiotl for devices with too small dma
> masks (and altix would need that one aswell if it tried to support such
> devices).

Something like that might be nice as part of the bridge driver work that's 
being discussed on lkml.  Machine vectors as they stand right now aren't a 
good fit since they're only initialized once for the platform at boot time, 
not on a per-chip basis.

Jesse
