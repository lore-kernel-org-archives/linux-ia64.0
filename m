From: Keith Owens <kaos@sgi.com>
Date: Fri, 06 Dec 2002 14:15:43 +0000
Subject: Re: [Linux-ia64] 2.5.50+ patch for the impatient...
Message-Id: <marc-linux-ia64-105590709805511@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805503@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805503@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 5 Dec 2002 00:13:59 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>For those of you who're impatiently waiting for a 2.5.xx update, I put
>a preliminary patch at:
>
>  ftp://ftp.hpl.hp.com/pub/linux-ia64/patch-2.5.50-1.968-lia64.diff.gz
>
>The patch is relative to revision 1.968 of Linus' bitkeeper tree
>(which is 2.5.50 with a bunch of additional patches).  Only the Ski
>simulator has been tested.  Kernel modules are definitely broken at
>the moment, since the ia64-part of the in-kernel module-loader is
>missing (I don't use modules myself and in any case it may be better
>to wait until things have settled down a bit; it looks like Rich
>Henderson has convinced Rusty to make modules effectively shared
>objects).

kdb for 2.5 kernels is also completely broken.  It needs the section
data in kallsyms and Rusty has deleted that information.  See
http://www.kerneltrap.org/node.php?idP0.  Do not expect kdb for any
2.5 kernel until Rusty puts the debugging data back.  And BTW, do not
expect ksymoops to work either.


