From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Tue, 11 Mar 2003 21:10:40 +0000
Subject: Re: [Linux-ia64] 2.4.20 / DIG
Message-Id: <marc-linux-ia64-105590709806032@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806024@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806024@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 11 March 2003 2:04 pm, Jes Sorensen wrote:
> >>>>> "Andreas" = Andreas Schwab <schwab@suse.de> writes:
> 
> Andreas> Try disabling CONFIG_IA64_MCA, IIRC this is a problem of a
> Andreas> missing hardware component.
> 
> Bingo! Give that man a cigar!
> 
> Thanks a lot, I am back in business!

Did you ever look at the MCA logs from the EFI shell?  It would be
nice if we could make the kernel smart enough to avoid this failure.

Andreas, do you remember any more details of the problem?

Bjorn


