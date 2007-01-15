From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 15 Jan 2007 15:44:29 +0000
Subject: Re: Disparity between esi.c & esi.h
Message-Id: <1168875869.14363.350.camel@bling>
List-Id: <linux-ia64.vger.kernel.org>
References: <5e0a1fd80701150147i666f76dp9292a77d1fa9d3cf@mail.gmail.com>
In-Reply-To: <5e0a1fd80701150147i666f76dp9292a77d1fa9d3cf@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2007-01-15 at 15:17 +0530, Karthik Gopalakrishnan wrote:
> Hi Folks.
> 
> esi.h has the following extern with no corresponding definition in esi.c
> extern int ia64_esi_init (void);
> 
> The closest definition in esi.c is the following:
> static int __init esi_init (void)
> {
> ...
> }
> 
> Is this an oversight or am I missing something? I am looking at the
> 2.6.19 sources.

Hi Karthik,

   I had an ia64_esi_init() in a previous version of this patch.  Looks
like it accidentally made it's way to the final version even though the
function became esi_init(), which doesn't need a prototype.  Thanks for
spotting this.

	Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

