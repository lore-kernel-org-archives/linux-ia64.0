From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 06 Jun 2006 14:12:55 +0000
Subject: Re: [RFC 1/2] Xen/ia64 modified files
Message-Id: <1149603175.5864.5.camel@lappy>
List-Id: <linux-ia64.vger.kernel.org>
References: <1149275354.5999.83.camel@lappy>
In-Reply-To: <1149275354.5999.83.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2006-06-06 at 05:15 -0400, Jes Sorensen wrote:
> Hi Alex,
> 
> A few comments:

Hi Jes,

   Thanks for the thorough review.  There is definitely still much to be
cleaned up before we think about including this.  Incorporating changes
into a Xen machvec is certainly on my wish list.  Some of the CONFIG_XEN
demarcations in the code are to make it easier for us to rebase the code
as we track upstream.  I hope to get rid of a lot of those as we
incorporate things like a better is_running_on_xen() check.  Thanks
again for you comments, we'll start incorporating them.

	Alex
-- 
Alex Williamson                             HP Open Source & Linux Org.

