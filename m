From: Alex Williamson <alex.williamson@hp.com>
Date: Thu, 04 Nov 2004 17:11:19 +0000
Subject: Re: [RFC] prefer allocations from nodes w/o CPUs
Message-Id: <1099588279.5561.1.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411040857.25664.jbarnes@engr.sgi.com>
In-Reply-To: <200411040857.25664.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2004-11-04 at 08:57 -0800, Jesse Barnes wrote:
> Small patch for the ia64 version of topology.h to make the zonelist building 
> code prefer nodes w/o CPUs for allocations.  Do any platforms aside from 
> Altix have nodes with only memory?  If not, then this will only affect sn2, 
> otherwise I'm interested in hearing feedback.

   Yes, hp sx1000 systems represent interleaved memory in a separate
node w/o cpus.

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

