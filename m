From: Dan Pop <Dan.Pop@cern.ch>
Date: Tue, 26 Jun 2001 02:38:50 +0000
Subject: Re: [Linux-ia64] Red Hat Installer cannot find the hard drive
Message-Id: <marc-linux-ia64-105590693005766@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005762@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005762@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, 25 Jun 2001, Stephane Eranian wrote:

> Hi,
> 
> On Mon, Jun 25, 2001 at 04:47:28PM -0700, Li, Shuo wrote:
> > Does anybody know what caused the following problem and how to fix it?

It usually happens if the disk has already been partioned by an older
RH version.  At least, this is what we have seen.  The solution is to
manually remove all the existing partitions (with fdisk) and then to
select the "Retry" option.

> > The problem happens at Linux install time. After the installer come back
> > after trying to detect the hard drive, it reports an error saying
> > 
> > Partiition(s)) do not end on cylinder boundary:
> 
> I don't know which version of RH you're trying to install. I know that
> in the past there was a problem here and that it would abort the install.
> The fix is to switch to a text console (Alt-Fx where x is maybe 6 or higher,
> I don't recall).

I think that Alt-F2 should bring you to a root shell session.  Anyway,
it's easy to find by trial and error.

> Then you invoke fdisk manually on the device. Note that the
> device entry may not be present.

It's present, but under /tmp.  Something like "fdisk /tmp/sda" should
do the job.

Dan


