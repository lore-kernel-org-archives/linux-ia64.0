From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 22 Jun 2004 15:59:11 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406220959.11522.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 22 June 2004 12:15 am, Grant Grundler wrote:
> I tried building a 2.6.7 kernel using my "standard" .config
> that worked for 2.6.6. The only source code changes were
> to include openib.org infiniband driver in the tree as modules.
> 
> Last output was:
> 	Console: colour VGA+ 80x25

David saw this late last week on a 2.6.7 kernel compiled for UP,
and I reproduced it yesterday using the current linux-ia64-2.5
BK bits.  I'm using a zx6000 with serial console (VGA also
present, but unused).  No MCA records.  I collected info from
an INIT, but haven't had a chance to look very far.  Something
in the error records pointed to efi_memmap_walk(), so I added
a printk there, and the problem disappeared.

David mentioned the linker in Debian/testing as a possibility.
I'm using ld 2.14.90.0.7 from Debian binutils 2.14.90.0.7-3.
