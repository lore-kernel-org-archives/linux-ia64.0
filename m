From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 08 Dec 2003 18:41:32 +0000
Subject: Re: [RFE] Add stacked registers to SAL records (resend)
Message-Id: <marc-linux-ia64-107091128712660@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106870740330038@msgid-missing>
In-Reply-To: <marc-linux-ia64-106870740330038@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 04 December 2003 5:59 pm, Keith Owens wrote:
> SAL error records contain most registers in sal_processor_static_info,
> but not the stacked registers.  What is the process for adding another
> GUID to the SAL specification to contain the stacked registers?

One of our architecture guys pointed out that the stacked registers
should still be intact at the OS_MCA and OS_INIT handoffs.  They
are unchanged in the PALE_CHECK and PALE_INIT exit state (I finally
found this buried in the RSE description), and the OS_MCA and OS_INIT
handoff state is defined to be the same for stacked registers.

So I assume your proposal is to address the fact that we don't
actually save the error records until after a reboot, and the
stacked register contents are gone by then.  Right?

Bjorn

