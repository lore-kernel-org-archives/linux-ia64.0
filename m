From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Tue, 18 Jan 2005 13:57:14 +0000
Subject: Re: [patch] Remove limit on MCA recoveries
Message-Id: <200501181357.j0IDvEoq001827@mtv-vpn-hw-mfl-1.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
In-Reply-To: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Agreed.  If you want to increase the static limit up from 32 to a thousand
> > or so, as an interim fix until such extra page_flags are agreed upon, then
> > I'll be ok with that.
> 
> Sounds good.  Thanks, Tony.  Here is a patch.
> 
> Of course very quickly _only_ 1024 recoveries won't be enough.  :-)

I think one option is a dynamic array, but any re-allocation would not be done
at MCA time. Once the table is full by 80% for example, we can increase it's size
at a somewhat more convenient time

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

