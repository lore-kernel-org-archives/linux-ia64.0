From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 18 Nov 2004 00:08:00 +0000
Subject: Re: [PATCH] Fix for kexec reboot failing after multiple continued kexec reboots
Message-Id: <200411171608.00258.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100633878.21234.15.camel@lyra.fc.hp.com>
In-Reply-To: <1100633878.21234.15.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, November 17, 2004 3:44 pm, Jesse Barnes wrote:
> It's dying in find_pernode_space.  The efi memmap, though trimmed, should
> be ok at this point, so I'm still trying to figure out what's going on in
> that routine.

Actually, it looks like the EFI memmap isn't the same between a regular boot
 and a kexec boot even though I'm not messing with it via mem= or anything.
I check it in find_pernode_space and though the start is the same, the
length isn't.  In the kexec kernel, the length that's passed in is much bigger
in fact.

Regular boot:
find_pernode_space(0000003003000000, 0000000011000000, 0): pernodesize = 33783808
found space at 0000003003000000

kexec boot:
find_pernode_space(0000003003000000, 0000000079000000, 0): pernodesize = 163840
found space at 0000003003000000

(the kexec kernel was configured for 2p, while the regular one was 512p, which
explains the difference in pernodesize requirements).  I think the kexec kernel
is corrupting all sorts of important memory since it thinks it's got pages that
it shouldn't be touching.

Thanks,
Jesse
