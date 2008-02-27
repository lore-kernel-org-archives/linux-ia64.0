From: Russ Anderson <rja@sgi.com>
Date: Wed, 27 Feb 2008 16:50:25 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC] regression:113134fcbca83619be4c68d0ca66db6093
Message-Id: <20080227165025.GB1908@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 26, 2008 at 05:34:19PM -0700, Alex Chiang wrote:
> > SAL 2.9: SGI SN2 version 1.30
> 
> I wouldn't expect SAL 2.9 to implement a call defined in SAL 3.2,
> unless I'm seriously misunderstanding something?

The answer is the 2.9 value is hardcoded in the Altix prom and
was not updated to 3.2 even though the prom supports SAL 3.2.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
