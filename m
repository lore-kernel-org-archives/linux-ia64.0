From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Tue, 18 Oct 2005 07:49:25 +0000
Subject: Re: perfmon not counting idle?
Message-Id: <20051018074925.GA3143@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051017093217.GA2446@frankl.hpl.hp.com>
In-Reply-To: <20051017093217.GA2446@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 17, 2005 at 02:32:17AM -0700, Stephane Eranian wrote:
> By default pfmon measures only at the user level (pl3).  If you want
> kernel+user you need to add -k. You can tune priv levels per event
> using --priv-levels.

Ah, oops.  Thanks :)

Matt

