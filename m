From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 07 Aug 2007 21:55:31 +0000
Subject: Re: [PATCH]utrace: IA64 RSE bug
Message-Id: <20070807215531.GA23261@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186464229.784.9.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1186464229.784.9.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

On Tue, Aug 07, 2007 at 12:13:16AM -0700, Roland McGrath wrote:
> That looks reasonable to me, not being expert on the ia64 details.  
> I rolled that into utrace-regset-ia64.patch in the 2.6.22 backport version.
> 
> > patch is against latest utrace source (2.6.22 base + utrace patches)
> 
> The latest utrace source is based on 2.6.23-rc2, and your patch does not
> apply there.  TIF_NOTIFY_RESUME has been renamed to TIF_PERFMON_WORK.
> So you need to rename it back (or to something else) to overload it.
> 

Yes, in 2.6.23, TIF_NOTIFY_RESUME has been removed because it was not used
except for perfmon, thus I renamed it. The problem is that you cannot just
override it because you would need a way to further demultiplex the
reason for call do_notify_resume(). Perfmon not simply relies  on the
TIF_PERFMON_WORK bit being set. As you realize now this flag would
mean you have some RSE work or some perfmon work. 


-- 
-Stephane
