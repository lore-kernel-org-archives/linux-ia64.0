From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 09 Feb 2005 20:03:31 +0000
Subject: RE: [PATCH] CPU hotplug returns CPUs to SAL
Message-Id: <1107979412.5478.69.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <1107970828.5478.22.camel@tdi>
In-Reply-To: <1107970828.5478.22.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-02-09 at 11:51 -0800, Luck, Tony wrote:
> >   But the BSP doesn't need to save anything.  We'll always have N-1 SAL
> >states saved and N-1 CPUs that can be taken offline.  As long as we
> >don't hard link a state to a specific CPU, we're in good shape.  I've
> >been testing on my boxes with an order that intentionally gives CPUs the
> >state saved off of another CPU on OS entry.  I appear to be able to make
> >the BSP return to SAL as well, but I don't think the rest of the hotplug
> >code is ready for this (the other CPU doesn't seem to be getting
> >scheduled).
> 
> That sounds worrying ... it assumes that the SAL thinks that
> cpus are fungible, which might not be true on ccNUMA systems.

   Ok, I suppose it could be interpreted that Table 3-2 defining cr.lid
as unchanged locks a state to a specific CPU... too bad.

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

