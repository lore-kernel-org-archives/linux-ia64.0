From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 07 Nov 2007 16:40:29 +0000
Subject: RE: [PATCH] Move dmi_scan_machine() call ealier
Message-Id: <1194453629.6463.27.camel@lappy>
List-Id: <linux-ia64.vger.kernel.org>
References: <1194370267.31834.176.camel@bling>
In-Reply-To: <1194370267.31834.176.camel@bling>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Wed, 2007-11-07 at 08:30 -0800, Luck, Tony wrote:
> >   Thanks for the review Simon.  Is the patch below more like what
> > you're thinking?  I agree that check_bugs doesn't initial seem like the
> > most appropriate place to setup DMI, but think about what DMI is
> > typically used for in the kernel.
> 
> Then re-name check_bugs() to something more suited to the things that
> it is now doing. [I think that was what Simon was hinting at].

   Re-naming check_bugs() becomes a cross architecture endeavor.  Since
x86 calls dmi_scan_machine() in setup_arch(), this would only be for
ia64.  Perhaps the right answer is to make dmi_scan_machine() callable
from setup_arch() on ia64, but that requires an safer early ioremap, and
I'm still not sure what that should look like.  Thanks,

	Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

