From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 30 Jun 2003 16:30:13 +0000
Subject: Re: IA-32 support patch: msgsnd/msgrcv return value off by 4
Message-Id: <marc-linux-ia64-105699112211245@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105649278110408@msgid-missing>
In-Reply-To: <marc-linux-ia64-105649278110408@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 24 June 2003 4:12 pm, Arun Sharma wrote:
> 
> The return value of do_sys32_msgsnd() is off by 4. This seems to be a bug inherited from sparc64, fixed in the x86_64 tree in 2.5.
> 
> Please apply to both 2.4 and 2.5 trees.

Applied to 2.4 (and David put it in 2.5 as well).

