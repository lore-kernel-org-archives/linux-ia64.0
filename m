From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 11 Sep 2003 15:22:17 +0000
Subject: Re: [PATCH] misc. sn2 updates
Message-Id: <marc-linux-ia64-106329427403484@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106304956024421@msgid-missing>
In-Reply-To: <marc-linux-ia64-106304956024421@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 11, 2003 at 07:51:18AM -0700, Jesse Barnes wrote:
> No, generic compiles won't work until the discontig patch gets merged
> somehow.  Did I accidentally reenable arch/ia64/sn/ as part of the
> generic target?  It should be commented out.

This is actually Jes' fault because he enables SN2-specific Hacks in
qla1280 for the generic build.  He hacked around my previous specific
complaint by using weak linking hacks, but your asm/sn/ changes show
once again that this idea is flawed..

