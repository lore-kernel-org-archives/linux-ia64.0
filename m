From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 30 Jun 2003 16:30:30 +0000
Subject: Re: IA-32 support patch: munmap should return EINVAL if size == 0
Message-Id: <marc-linux-ia64-105699112311251@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105649312310734@msgid-missing>
In-Reply-To: <marc-linux-ia64-105649312310734@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 24 June 2003 4:16 pm, Arun Sharma wrote:
> 
> Native IA-32 returns EINVAL on a unmap of size 0. Our behavior is currently not compatible.
> 
> Please apply to both 2.4 and 2.5.

Applied to 2.4 (and David put it in 2.5 as well).

