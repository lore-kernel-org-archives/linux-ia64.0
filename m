From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 01 Sep 2004 15:24:21 +0000
Subject: Re: [1/1] make bad_page() print all of page->flags
Message-Id: <200409010924.21724.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040901061443.GW5492@holomorphy.com>
In-Reply-To: <20040901061443.GW5492@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 01 September 2004 1:28 am, Ian Wienand wrote:
> On Tue, Aug 31, 2004 at 11:14:43PM -0700, William Lee Irwin III wrote:
> > (3) "stops dead" isn't a very good description; deadlock? livelock?
> > 	interrupts on or off?
> 
> It doesn't respond to magic-sysrq and I guess it takes an MCA because
> it spontaneously reboots after about 10 seconds, though doesn't print
> anything useful before it does that.

You mentioned this was an HP rx2600.  You can tell for sure whether it
was an MCA (and get useful information about it) by doing "errdump clear"
at the EFI shell prompt before reproducing the problem, stopping at the
EFI shell prompt again during the subsequent reboot, and doing
"errdump mca".

There's also a "salinfo" package that automatically retrieves and logs
this information.  It's part of Debian, there are sources here:

    ftp://ftp.kernel.org/pub/linux/kernel/people/helgaas

or I can send you an RPM for RHEL3 if you need it.
