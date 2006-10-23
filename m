From: Horms <horms@verge.net.au>
Date: Mon, 23 Oct 2006 08:48:40 +0000
Subject: [patch 0/5] Physical mode SAL calls
Message-Id: <20061023084840.730815639@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I am reposting this series of patches, as some of the posts that made up
the original series seem to have never made the list.

Currently the EFI code will fallback to physical mode if it
can't map itself into virtual memory. However, if this occurs
SAL calls fail, because the kernel runs them in virtual mode regardless.
This fails because sometimes the PAL calls actually call EFI code
internally, expecting it to be maped into a virtial area of memory,
which it isn't.

This series of patches also addes a kernel command line option
to force EFI (and SAL) to stay in physical mode. This is primarily
for testing that physical mode calls work with this patchset.

But I believe that physical mode EFI calls will be needed
to successfully kexec between kernels (or hypervisors) that
have a different PAGE_OFFSET (e.g. linux and xen), as
the EFI code can only be mapped zero or one times. That is,
if linux maps it, xen won't be able to run, and vice versa.
But by staying with physical mode calls the problem goes away.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

