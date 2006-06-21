From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 21 Jun 2006 23:19:58 +0000
Subject: patches added to release/test trees
Message-Id: <200606212319.k5LNJw7e014316@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
In-Reply-To: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I just did a quick skim through my backlog of patches and pushed
all the "obviously correct" (famous last words) ones into the
release tree.  I'll send them to Linus on Friday (unless I hear
about any problems).  Remind me about any other "obvious" stuff
that my eyes skipped over.

The following patches have been added to the release tree:

Alex Williamson:
      [IA64] add vmlinuz target
      [IA64] sanity check reserved region usage

Bjorn Helgaas:
      [IA64] rework memory attribute aliasing

David Mosberger-Tang:
      [IA64] make efi_stub.S fit in 80 cols

Ian Wienand:
      [IA64] SKI Simulator boot

Jack Steiner:
      [IA64-SGI] SN topology fix for large systems

Keith Owens:
      [IA64] Sanitize assembler code for ia64_sal_os_state

Kenji Kaneshige:
      [IA64] Make PCI Express support selectable

Mike Habeck:
      [IA64-SGI] fix SGI Altix tioce_bus_fixup() bug

Russ Anderson:
      [IA64-SGI] Remove SN SAL error handling feature bit that is no longer needed


Additionally the following patches have been added to the test tree. These
will probably go to Linus before we get to -rc1.

David Mosberger-Tang:
      [IA64] esi-support

Tony Luck:
      [IA64] Add "model name" to /proc/cpuinfo


Horms and Ian.  Thanks for all the kexec patches you've posted.  I'll
be folding them in on top of the current kexec stuff soon.  There
still seem to be a lot of open issues on this, and hardly any reports
of any testing going on.  At this pace kexec/kdump will be sitting in
"test" (and -mm) for at least another release cycle.
