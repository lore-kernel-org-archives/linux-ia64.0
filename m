From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Tue, 11 Mar 2003 21:18:00 +0000
Subject: Re: [Linux-ia64] 2.4.20 / DIG
Message-Id: <marc-linux-ia64-105590709806034@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806024@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806024@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 11 March 2003 2:15 pm, Jes Sorensen wrote:
> Bjorn> Did you ever look at the MCA logs from the EFI shell?  It would
> Bjorn> be nice if we could make the kernel smart enough to avoid this
> Bjorn> failure.
> 
> Must admit I didn't - are those preserved across a power cycle?

They should be.  Of course, it will only make sense if you still
have symbols from the kernel that caused the MCA.

