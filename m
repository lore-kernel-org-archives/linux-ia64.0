From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 16 Apr 2003 16:09:09 +0000
Subject: Re: [Linux-ia64] Unwinder bug
Message-Id: <marc-linux-ia64-105590723705510@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705308@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705308@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 25 March 2003 6:41 am, Andreas Schwab wrote:
> I've found this by inspecting the code: pt_regs_off returns an offset into
> struct pt_regs.  Relative to latest bk, 2.5 has the same bug.

I applied this to 2.4 as well.

Bjorn


