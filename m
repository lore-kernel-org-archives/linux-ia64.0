From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 22 Jul 2003 14:33:51 +0000
Subject: Re: a nice way to reboot :-)
Message-Id: <marc-linux-ia64-105888452806386@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105887789030732@msgid-missing>
In-Reply-To: <marc-linux-ia64-105887789030732@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 22 July 2003 7:31 am, Bruno Cornec wrote:
> Grant Grundler (iod00d@hp.com) said:
> 
> > On Tue, Jul 22, 2003 at 02:32:54PM +0200, Bruno Cornec wrote:
> > > On Linux/ia64 when you do cat /proc/kcore, the system just reboots in a couple
> > > of seconds (with RHAS 2.1 std kernel, updated kernel - 2.4.18-e.31) or even with a 
> > > vanilla 2.4.21 + david's patches.
> > 
> > Known behavior. 
> 
> Humm :-) I tend to find that hardly acceptable that people can crash so easily 
> a system. 

Believe me, this has been on our list of really annoying things
for a long time.  The fact that this is just one of many ways that
root can crash the box has meant that it hasn't made it to the
top of the list (yet).  It'll be there soon, though...

Bjorn

