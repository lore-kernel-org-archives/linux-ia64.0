From: Leif Lindholm <leif.lindholm@linaro.org>
Date: Thu, 05 Sep 2013 10:23:52 +0000
Subject: Re: [PATCH v3 2/5] efi: provide a generic efi_config_init()
Message-Id: <20130905102352.GV18151@rocoto.smurfnet.nu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1375901660-23541-1-git-send-email-leif.lindholm@linaro.org>
 <1375901660-23541-3-git-send-email-leif.lindholm@linaro.org>
 <20130902092902.GE28598@console-pimps.org>
In-Reply-To: <20130902092902.GE28598@console-pimps.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Matt Fleming <matt@console-pimps.org>
Cc: linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, tony.luck@gmail.com, grant.likely@secretlab.ca

On Mon, Sep 02, 2013 at 10:29:02AM +0100, Matt Fleming wrote:
> This patch actually breaks git bisection,
 
Urgh, sorry about that.

> /home/build/git/efi/arch/x86/platform/efi/efi.c:581:19: error: conflicting types for ‘efi_config_init’
> In file included from /home/build/git/efi/arch/x86/platform/efi/efi.c:33:0:
> /home/build/git/efi/include/linux/efi.h:596:12: note: previous declaration of ‘efi_config_init’ was here
> 
> I've merged patches 2,3 and 4 into the following single patch so that
> the ability to bisect isn't lost. Does it look OK? It boots fine on my
> test machines.

Looks fine to me, and works on the ARM port.
I'm about to send out an updated patch set, including this squash.

/
    Leif
