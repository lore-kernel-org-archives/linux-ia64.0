From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 13 Mar 2002 20:26:28 +0000
Subject: Re: [Linux-ia64] qla1280 driver update
Message-Id: <marc-linux-ia64-105590701905262@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905261@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905261@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You wouldn't happen to know where I could find a patch like this for
qlogicfc.c, would you?  It doesn't look like it works in 2.5.5
either...

Thanks,
Jesse

On Wed, Mar 13, 2002 at 02:42:34PM -0500, Jes Sorensen wrote:
> Hi
> 
> For those of you who wants to play with the updated qla1280 driver with
> the latest kernels, an updated patch relative to David's 2.5.5 release
> can be found at:
> 
> http://www.wildopensource.com/~jes/linux/qla-3.23.11.diff.gz
> 
> I haven't done extensive testing of this under 2.5.5, it's basically
> just a port to 2.5.5 from the old 2.4.17 based (ie. spin lock changes to
> match the better locking in 2.5.x).
> 
> Cheers,
> Jes
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

