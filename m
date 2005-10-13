From: Greg Edwards <edwardsg@sgi.com>
Date: Thu, 13 Oct 2005 13:10:04 +0000
Subject: Re: [PATCH] set altix preferred console
Message-Id: <20051013131004.GB7542@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050930200422.GD13855@sgi.com>
In-Reply-To: <20050930200422.GD13855@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 12, 2005 at 01:55:02PM -0500, Mark Maule wrote:
| New version of Greg's original patch per review comments from Bjorn:
| 
| 
| Fix default VGA console on SN platforms.  Since SN firmware does not pass
| enough ACPI information to identify VGA cards and the associated legacy IO/MEM
| addresses, we rely on the EFI PCDP table.  Since the linux pcdp driver is
| optional (and overridden if console= directives are used) SN duplicates a
| portion of the pcdp scan code to identify if there is a usable console VGA
| adapter.
| 
| To avoid also dup'ing PCDP structures, drivers/firmware/pcdp.h is moved to
| include/linux/pcdp.h.
| 
| Signed-off-by: Mark Maule <maule@sgi.com>

Acked-by: Greg Edwards <edwardsg@sgi.com>

This does fix the problem I was experiencing earlier while booting with
console= boot options.
