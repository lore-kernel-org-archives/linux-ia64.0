From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 03 Feb 2004 23:29:37 +0000
Subject: Re: PCI question
Message-Id: <20040203232936.GB10362@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
In-Reply-To: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 03, 2004 at 05:15:44PM -0600, Patrick Gefre wrote:
> >Urgh, don't do that.  What do you need to do that can't be added to the
> >pci_controller?
>
> OK- good - thanks. Yes the other option is to add it to the 
> pci_controller struct.

Add what?  How about pci_controller->platform_data?  That's private to
the subarch, right?

Jesse
