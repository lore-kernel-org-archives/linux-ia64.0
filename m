From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 26 Aug 2003 20:25:32 +0000
Subject: Re: IA-32 compatibility patch: FP denormal handling
Message-Id: <marc-linux-ia64-106192998906755@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106141205114677@msgid-missing>
In-Reply-To: <marc-linux-ia64-106141205114677@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 20 August 2003 2:39 pm, Arun Sharma wrote:
> 
> The following patch makes ia64 compatible with i386 with respect to siginfo.si_code on FP denormal operands. This is necessary for the correct emulation of many IA-32 apps.
> 
> Please apply to both 2.4 and 2.5.

Applied for 2.4, thanks!

