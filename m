From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 02 Mar 2005 00:03:31 +0000
Subject: Re: efibootmgr fixes for EFI 1.10
Message-Id: <1109721812.12409.114.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <1109719371.12409.81.camel@tdi>
In-Reply-To: <1109719371.12409.81.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-03-02 at 01:01 +0100, Andreas Schwab wrote:
> Alex Williamson <alex.williamson@hp.com> writes:
> 
> >    Then you get something like this printed:
> >
> > ** Warning ** : BootFFFF-8be4df61-93ca-11d2-aa0d-00e098032b8c has same label Linux
> >
> > Seemed like too much information.  Thanks,
> 
> Then use %.8s.  Likewise for all other occurences of the same theme.

  D'oh, thanks.  I'll fix those.

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

