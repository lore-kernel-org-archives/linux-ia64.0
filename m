From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 03 Apr 2017 17:27:00 +0000
Subject: Re: [PATCH v2] nfc: don't be making arch specific unaligned decisions at driver level.
Message-Id: <20170403172659.GN2713@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201701090839.5u37Hdez%fengguang.wu@intel.com>
 <20170109175222.3162-1-paul.gortmaker@windriver.com>
 <20170401222244.GF22034@zurbaran.ger.intel.com>
In-Reply-To: <20170401222244.GF22034@zurbaran.ger.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Samuel Ortiz <sameo@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, kbuild test robot <lkp@intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-wireless@vger.kernel.org

[Re: [PATCH v2] nfc: don't be making arch specific unaligned decisions at driver level.] On 02/04/2017 (Sun 00:22) Samuel Ortiz wrote:

> Hi Paul,
> 
> On Mon, Jan 09, 2017 at 12:52:22PM -0500, Paul Gortmaker wrote:
> > Currently ia64 fails building allmodconfig with variations of:
> > 

[...]

> > 
> >  drivers/nfc/nfcmrvl/fw_dnld.c  | 2 +-
> >  drivers/nfc/nxp-nci/firmware.c | 2 +-
> >  drivers/nfc/nxp-nci/i2c.c      | 2 +-
> >  3 files changed, 3 insertions(+), 3 deletions(-)
> This build issue is now fixed in nfc-next with a couple of different
> patches.

OK, I'll remove it from my local queue and retest and let you know if I
see any issues still.

Thanks,
Paul.
--

> 
> Cheers,
> Samuel.
