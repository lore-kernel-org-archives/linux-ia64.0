From: Grant Grundler <iod00d@hp.com>
Date: Tue, 22 Jul 2003 13:05:57 +0000
Subject: Re: a nice way to reboot :-)
Message-Id: <marc-linux-ia64-105887917932130@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105887789030732@msgid-missing>
In-Reply-To: <marc-linux-ia64-105887789030732@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 22, 2003 at 02:32:54PM +0200, Bruno Cornec wrote:
> On Linux/ia64 when you do cat /proc/kcore, the system just reboots in a couple
> of seconds (with RHAS 2.1 std kernel, updated kernel - 2.4.18-e.31) or even with a 
> vanilla 2.4.21 + david's patches.

Known behavior. David Mosberger tells me Tony Luck changed the support in
2.6 such that only valid regions are accessible. Don't expect it fixed in RHAS
anytime soon. You might check if Bjorn Helgaas' ia64 patch on top of 2.4.21
fixes the same problem.

grant
