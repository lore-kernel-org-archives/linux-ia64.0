From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 22 May 2003 15:39:23 +0000
Subject: RE: [Linux-ia64] new ia64 patch (relative to 2.5.69)
Message-Id: <marc-linux-ia64-105590723705983@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705980@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705980@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David wrote:
> An updated 2.5.69 patch is now available at:
> 
>  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/
> 
> in linux-2.5.69-ia64-030521.diff.gz.

This patch includes my kernel relocation change (yipee!) ... don't
be surprised when you see kernel addresses like 0xA0000001000xxxxx
instead of the 0xE0000000000xxxxx that you've been used to in ia64.

-Tony

