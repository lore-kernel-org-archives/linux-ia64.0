From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 30 Jun 2003 16:30:45 +0000
Subject: Re: IA-32 support patch: mmap should return ENOMEM
Message-Id: <marc-linux-ia64-105699112211246@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105649349511116@msgid-missing>
In-Reply-To: <marc-linux-ia64-105649349511116@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 24 June 2003 4:21 pm, Arun Sharma wrote:
> 
> Single Unix Specification says:
> [ENOMEM] MAP_FIXED was specified, and the range [addr, addr + len) exceeds that allowed for the address space of a process.
> 
> Therefore if addr + len > IA32_PAGE_OFFSET, we should return ENOMEM.
> 
> Please apply to both 2.4 and 2.5.

Applied to 2.4 (and David put it in 2.5 as well).

