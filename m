From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Fri, 10 Sep 2004 04:22:44 +0000
Subject: Re: [PATCH] 2.6.9-rc1 Ia64 build broken due to HPET
Message-Id: <20040910042244.GO5668@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040910041200.GN5668@cse.unsw.EDU.AU>
In-Reply-To: <20040910041200.GN5668@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Darren

On Fri, 10 Sep 2004, Darren Williams wrote:

> The ia64 build broke overnight due to this patch
> http://marc.theaimsgroup.com/?l=linux-ia64&m9211170801213&w=2
> any ia64 arch that includes CONFIG_HPET will fail
> on the build, this effect generic_defconfig also.
> 
> 
Me slow see:
http://marc.theaimsgroup.com/?l=linux-ia64&m9468628322563&w=2

--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
