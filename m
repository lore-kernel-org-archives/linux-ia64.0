From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 27 Apr 2004 14:46:19 +0000
Subject: Re: [PATCH] bug w/ shared interrupts
Message-Id: <1083077178.2778.76.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <1082989740.15656.20.camel@localhost>
In-Reply-To: <1082989740.15656.20.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-04-26 at 15:12, David Mosberger wrote:
> >>>>> On Mon, 26 Apr 2004 08:29:00 -0600, Alex Williamson said:
> 
>   Alex>    I just ran into a bug introduced by cset 1.1371.519.37.
> 
> Note that cset numbers are not globally unique.  Since you didn't specify
> which repository you used, I'm not sure which cset you're referring to.
> To get a globally unique cset id, you can use:
> 
>   $ bk changes -k -r1.1371.519.37
> 


   Sorry, seems like I've made this mistake before.  I'm using the
linux-2.5 repository:

$ bk changes -k -r1.1371.519.37:

(email munged)
kaneshige.kenji at jp dot fujitsu dot com|ChangeSet|20040311072739|26139

http://linux.bkbits.net:8080/linux-2.5/cset@405014ebFyD871H8goGX9hQG7Un99g?nav=index.html|src/|src/arch|src/arch/ia64|src/arch/ia64/kernel|related/arch/ia64/kernel/iosapic.c

Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

