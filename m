From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 20 Oct 2004 20:50:49 +0000
Subject: Re: [PATCH] sparse cleanups/fixes for sn2
Message-Id: <200410201350.49401.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F023B5DF2@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F023B5DF2@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, October 20, 2004 1:42 pm, Luck, Tony wrote:
> >This is a big patch mostly because I trimmed shub_mmr.h down
> >from 17M to 11k or so.  It fixes a number of things sparse discovered and
> >removes some dead code, fixes up some prototypes, etc.
>
> Applied ... but please don't send another "everything and the kitchen sink"
> patch like this again.

Sorry about that.  I considered omitting the shub_mmr.h part, but it's big no 
matter what, and the rest really was sparse cleanups...

Jesse
