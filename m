From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 06 Mar 2003 21:59:40 +0000
Subject: [Linux-ia64] Re: fix for siginfo.si_addr on NaT page triggered SIGSEGV
Message-Id: <marc-linux-ia64-105590709805991@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 06 March 2003 2:26 pm, David Mosberger wrote:
> The patch below fixes a bug which caused si_addr to be set to the
> faulting IP instead of the faulting data address when a SIGSEGV got
> triggered by the NaT page.  The patch is relative to 2.5, but I
> believe it applies on 2.4 as well.

I applied this to 2.4.

