From: Thibaut VARENE <T-Bone@parisc-linux.org>
Date: Mon, 07 Mar 2005 19:29:36 +0000
Subject: Re: efibootmgr fixes for EFI 1.10
Message-Id: <20050307202936.577cfff5@Tatooine.r3z0>
List-Id: <linux-ia64.vger.kernel.org>
References: <1109719371.12409.81.camel@tdi>
In-Reply-To: <1109719371.12409.81.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 01 Mar 2005 17:03:31 -0700
Alex Williamson <alex.williamson@hp.com> wrote:

> On Wed, 2005-03-02 at 01:01 +0100, Andreas Schwab wrote:
> > Alex Williamson <alex.williamson@hp.com> writes:
> > 
> > >    Then you get something like this printed:
> > >
> > > ** Warning ** : BootFFFF-8be4df61-93ca-11d2-aa0d-00e098032b8c has
> > > same label Linux
> > >
> > > Seemed like too much information.  Thanks,
> > 
> > Then use %.8s.  Likewise for all other occurences of the same theme.
> 
>   D'oh, thanks.  I'll fix those.

Hi

I'd be quite interested in having these changes into Ubuntu (and possibly
into Debian as well, assuming Bdale wants them), so I'd like to know
whether you have updated version of that patch you're happy with?

Thx

Thibaut VARENE
The PA/Linux ESIEE Team
http://www.pateam.org/
