From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 11 Sep 2003 00:16:18 +0000
Subject: Re: [PATCH] misc. sn2 updates
Message-Id: <marc-linux-ia64-106324202622484@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106304956024421@msgid-missing>
In-Reply-To: <marc-linux-ia64-106304956024421@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 08, 2003 at 12:19:44PM -0700, Jesse Barnes wrote:
> Fix a couple of sn2 files.

I'm not sure if it was this change, but something like it appears to
have broken the qla1280 driver when building with CONFIG_GENERIC :

In file included from include/asm/sn/pci/pciio.h:20,
                 from drivers/scsi/qla1280.c:382:
include/asm/sn/hcl.h:82: error: syntax error before "invplace_t"
include/asm/sn/hcl.h:83: warning: function declaration isn't a prototype
include/asm/sn/hcl.h:84: error: syntax error before "major_t"
include/asm/sn/hcl.h:84: warning: function declaration isn't a prototype
include/asm/sn/hcl.h:85: error: syntax error before "major_t"
include/asm/sn/hcl.h:85: warning: function declaration isn't a prototype
drivers/scsi/qla1280.c: In function `qla1280_64bit_start_scsi':
drivers/scsi/qla1280.c:3693: warning: implicit declaration of function `sn_pci_set_vchan'

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au
