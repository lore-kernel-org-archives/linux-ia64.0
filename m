From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 03 Mar 2004 19:03:26 +0000
Subject: Re: [PATCH] don't assume iosapic interrupt controllers
Message-Id: <16454.11262.62539.919876@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040301224526.GA22182@sgi.com>
In-Reply-To: <20040301224526.GA22182@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 3 Mar 2004 09:28:35 -0800, jbarnes@sgi.com (Jesse Barnes) said:

  Jesse> Some ia64 machines don't use an iosapic interrupt controller
  Jesse> (a flagrant violation of the DIG64 spec, gasp!), so don't
  Jesse> assume it's there in mca.c.  This patch got no complaints
  Jesse> last time I posted it, so I'm proposing it for inclusion.

Your changelog explains why you want to remove the offending code.  It
doesn't explain why the change is safe for those machines that do have
I/O SAPIC.  Please provide a complete ChangeLog entry (along with the
patch).

Thanks,

	--david
