From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Mon, 18 Jun 2001 17:39:09 +0000
Subject: Re: [Linux-ia64] eepro100 and nfs - mission impossible ?
Message-Id: <marc-linux-ia64-105590693005738@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005736@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005736@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 18, 2001, David Mosberger <davidm@hpl.hp.com> wrote:
> >>>>> On Mon, 18 Jun 2001 15:18:39 +0200, Jan Schreckenbach <Jan.Schreckenbach@sap.com> said:
> 
>   Jan> Hello, the problems with the eepro100 driver in conjunction
>   Jan> with NFS driving me mad. I'm using NFS very heavy for compiling
>   Jan> and installing (both: autofs and hand mounted shares).
>   Jan> Processes often hanging while accessing files on NFS shares (I
>   Jan> have seen a cp process hanging after aprox. 100MB on exactly
>   Jan> the same point of the file, regardless how often I tried).  I
>   Jan> use Lion's with BIOS 76 with the latest SuSE and Red Hat
>   Jan> distros.  The e100 driver does not work as well.  Are there any
>   Jan> chances to get it running???
> 
> This is *not* a problem with the eepr100 driver.  It's a bug in the
> eepro firmware.  A relatively easy workaround is to install your own
> network adapter and ignore the built-in one.

You are absolutely correct in the diagnosis of the problem.

BIOS 79 fixes this problem. I haven't checked if it is released yet.

JE


