From: Christoph Lameter <clameter@sgi.com>
Date: Sat, 11 Sep 2004 15:43:21 +0000
Subject: Re: [PATCH] 2.6.9-rc1 Ia64 build broken due to HPET
Message-Id: <Pine.LNX.4.58.0409110838310.15088@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040910041200.GN5668@cse.unsw.EDU.AU>
In-Reply-To: <20040910041200.GN5668@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 12 Sep 2004, Darren Williams wrote:

> Hi Christoph
> I have tested the patch and all compiles for zx1_defconfig+hpet, I see
> that it has been applied to main stream already, however I do not see
> any init messages in dmesg for hpet initialisation.
> At what point should I be seeing the init message?
>
> I have posted the config and dmesg output at:
> http://quasar.cse.unsw.edu.au/~dsw/public-files/hpet/

There is no dmesg line showing that a hpet device has been detected. Are
you sure that the box provides a hpet timer? If its not detected then you
better talk with the author of the hpet driver.
