From: peterc@gelato.unsw.edu.au
Date: Mon, 05 Jul 2004 01:14:22 +0000
Subject: Re: [PATCH] Add PCDP console detection support
Message-Id: <16616.43886.36556.270219@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200406251504.50579.bjorn.helgaas@hp.com>
In-Reply-To: <200406251504.50579.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Bjorn" = Bjorn Helgaas <bjorn.helgaas@hp.com> writes:

Hi Bjorn
   Changeset rmk@flint.arm.linux.org.uk|ChangeSet|20040701140332|57856
broke the pcdp.c console setup, because it removes UPF_RESOURCES.

P ChangeSet
C [SERIAL] Remove UPF_RESOURCES
C 
C The UPF_RESOURCES flag was added to the serial layer to cater for
C the idiosyncrasies of the PCMCIA layer, where the PCMCIA core code
C handles the claiming of busy resources.
C 
C However, the PCMCIA core has progressed, and now does not claim busy
C resources - IOW, it now behaves just like any other bus driver,
C where resources are allocated non-busy and its up to the drivers to
C mark their regions busy using request_region / request_mem_region.
C 
C The effect of this is that the UPF_RESOURCES hack in the serial
C layer is now redundant, and can now be removed - 8250 devices
C should now always use request_region / request_mem_region
C unconditionally.
C 
C Signed-off-by: Russell King.


I fixed here temporarily by just removing the UPF_RESOURCES flag, but
really something more than that is needed.


--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
