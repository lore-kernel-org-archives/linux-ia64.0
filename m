From: Ashok Raj <ashok.raj@intel.com>
Date: Fri, 25 Feb 2005 20:27:21 +0000
Subject: Re: [patch]:MC/MT enabling/identification for IA-64
Message-Id: <20050225122720.A9055@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 25, 2005 at 12:12:34PM -0800, Seth, Rohit wrote:
> 
>    Will following work:
> 
>    Physical id: Identifying the unique physical package id for LEU

The spec states that physical processor id or (die id) is not required
to be unique.  Are you depending on this being unique?

also PAL_LOGICAL_TO_PHYSICAL states that num_log (or total number of logical
processors in this die) doesnt necessarily need to be cpp * tpc)

just fyi: even if the numbers might be the same in most cases, its possible
that they could be different, because one thread didnt boot due to some 
failure)

>    Core id: Identifying the unique core id on that specific physical
>    package
>    Siblings: Identifying the total number LEUs on that physical package.
> 
>    Siblings is the one that apps have already started using on i386.
> 
>    -rohit
>    -
>    To  unsubscribe from this list: send the line "unsubscribe linux-ia64"
>    in
>    the body of a message to majordomo@vger.kernel.org
>    More majordomo info at  [2]http://vger.kernel.org/majordomo-info.html
> 
> References
> 
>    1. mailto:davidm@napali.hpl.hp.com
>    2. http://vger.kernel.org/majordomo-info.html

-- 
Cheers,
Ashok Raj
