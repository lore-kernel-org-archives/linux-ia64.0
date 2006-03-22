From: Jes Sorensen <jes@sgi.com>
Date: Wed, 22 Mar 2006 11:00:40 +0000
Subject: Re: [PATCH] ia64: sn_check_intr: use ia64_get_irr()
Message-Id: <yq03bhavj53.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603211044.07101.bjorn.helgaas@hp.com>
In-Reply-To: <200603211044.07101.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Bjorn" = Bjorn Helgaas <bjorn.helgaas@hp.com> writes:

Bjorn> Use the recently-added ia64_get_irr() rather than duplicating
Bjorn> the code.  I don't have hardware to test this.

Hi Bjorn,

Except for the vile formatting of ia64_get_irr() then I am all in
favor! It compiles, it boots! Ship it!

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Signed-off-by: Jes Sorensen <jes@sgi.com>
