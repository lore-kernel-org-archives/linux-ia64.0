From: Grant Grundler <iod00d@hp.com>
Date: Mon, 07 Mar 2005 23:50:39 +0000
Subject: Re: PCI Express
Message-Id: <20050307235039.GC2164@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 07, 2005 at 03:40:56PM -0800, Jesse Barnes wrote:
> Cool, I was hoping it just pointed at the same place we use for IPIs.  It 
> *should* work on Altix then, assuming the MSI allocation routines don't have 
> platform knowledge in them (like ACPI bits or something).

I submitted a patch to add MSI support to tg3:
	ftp://ftp.parisc-linux.org/patches/diff-2.6.10-tg3_MSI-03

It was rejected because of HW bugs in bcm57xx chips.
But it seems to work fine for me on the HP ZX1 platforms.
Maybe it's worth trying on the altix boxes as well.

grant
