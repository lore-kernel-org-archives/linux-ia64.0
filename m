From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 18 Feb 2004 19:06:22 +0000
Subject: Re: PXM/Nid/SLIT patch
Message-Id: <20040218190622.GN13235@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40321CF7.5020301@hp.com>
In-Reply-To: <40321CF7.5020301@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 18, 2004 at 01:56:48PM -0500, Robert Picco wrote:
> >I know HP basically owns the IA64 ports, but honestly can't you fix
> >the firmware to return sane information instead?  i.e. move the above
> >fix to firmware instead of letting linux fixup the reported data.
>
> Well some of us would like to see this too.  Some legacy requirements 
> from our other supported OSes require this to be the default 
> configuration.  Perhaps a different default can be made in the future or 
> some IPMI tool to change the default.

Ah, that explains it, it's what I expected (I've heard of other NUMA
boxes that do this too).  Hmm...

Jesse
