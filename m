From: Greg Edwards <edwardsg@sgi.com>
Date: Tue, 06 Dec 2005 15:01:48 +0000
Subject: Re: [PATCH] altix: pci_window fixup
Message-Id: <20051206150148.GA13100@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051129223714.2596.42757.40171@attica.americas.sgi.com>
In-Reply-To: <20051129223714.2596.42757.40171@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, Dec 06, 2005 at 08:52:38AM -0600, John Keller wrote:
| Tony,
|  There have been no comments on this patch, which
| was submitted a week ago. Can you pick this up?
|=20
| Thanks,
| John
|=20
| -------------------------
|=20
|=20
| Altix only patch to add fixup code that sets up=20
| pci_controller->window. This code is a temporary
| fix until ACPI support on Altix is added.
|=20
| Also, corrects the usage of pci_dev->sysdata,
| which had previously been used to reference
| platform specific device info, to now point to
| a pci_controller struct.
|=20
|=20
| Signed-off-by: John Keller <jpk@sgi.com>

This would be nice to push for 2.6.15, too, as this fixes an MCA when
starting graphics in pci_map_rom() that started with this changeset:

http://kernel.org/git/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dcomm=
itdiff;h=8085ce084c0f0144c353963853f81486fc331120;hp19e76a1ae835c34a2838c2b=
febe3db4d5a6b387

Greg
