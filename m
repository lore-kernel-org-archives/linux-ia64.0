From: Grant Grundler <iod00d@hp.com>
Date: Wed, 04 Feb 2004 17:48:42 +0000
Subject: Re: PCI question
Message-Id: <20040204174842.GB25250@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
In-Reply-To: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 04, 2004 at 11:04:42AM -0600, Patrick Gefre wrote:
> I think the 2.4 definition will be fine - at least for now. Was there a 
> reason it was changed in 2.6 ?

Because no one was using it?

Pat,
two (three?) people have asked you to state what you want to add.
Can you state the basic problem additional data fields would solve?

It might be easier to just add those fields directly to pci_controller
instead of messing with platform_data.

grant
