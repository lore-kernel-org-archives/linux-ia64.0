From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 05 Dec 2002 17:06:51 +0000
Subject: Re: [Linux-ia64] 2.5.50+ patch for the impatient...
Message-Id: <marc-linux-ia64-105590709805504@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805503@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805503@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks David.  Does this mean that your 'to-linus' tree will compile?
If so, I could just use that to send out an SN update (one that
compiles, btw), otherwise I'll generate a patch against this version and
hopefully have it to you next week.

Thanks,
Jesse

On Thu, Dec 05, 2002 at 12:13:59AM -0800, David Mosberger wrote:
> For those of you who're impatiently waiting for a 2.5.xx update, I put
> a preliminary patch at:
> 
>   ftp://ftp.hpl.hp.com/pub/linux-ia64/patch-2.5.50-1.968-lia64.diff.gz
> 
> The patch is relative to revision 1.968 of Linus' bitkeeper tree
> (which is 2.5.50 with a bunch of additional patches).  Only the Ski
> simulator has been tested.  Kernel modules are definitely broken at
> the moment, since the ia64-part of the in-kernel module-loader is
> missing (I don't use modules myself and in any case it may be better
> to wait until things have settled down a bit; it looks like Rich
> Henderson has convinced Rusty to make modules effectively shared
> objects).
> 
> I hope to have a more complete update by the time Linus gets ready to
> relese 2.5.51.  So if you're not urgently waiting for 2.5.50, you
> might want to wait till then.
> 
> Enjoy,
> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

