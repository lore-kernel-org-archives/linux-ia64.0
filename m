From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Date: Thu, 17 Jul 2003 18:42:38 +0000
Subject: RE: [PATCH] remove pa->va->pa conversion for efi.acpi
Message-Id: <marc-linux-ia64-105846801515626@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105797540229907@msgid-missing>
In-Reply-To: <marc-linux-ia64-105797540229907@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Note that I'm only pointing this out because I thought there were some
> NULL-pointer checks.  If it's a physical address, 0 is a valid
> address.  If it's an (identity-mapped) kernel address, NULL-pointer
> checks are OK.
> 

Doh!  Yes, indeed.  Thanks...

matt 
