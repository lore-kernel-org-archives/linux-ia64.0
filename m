From: Jes Sorensen <jes@sgi.com>
Date: Sat, 11 Mar 2006 08:51:41 +0000
Subject: Re: [RFC] IA64: Use early_parm to handle mvec_name and nomca
Message-Id: <44128F9D.7050402@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060310082445.GA18715@verge.net.au>
In-Reply-To: <20060310082445.GA18715@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Horms wrote:
> 
> Below is a fressh diff that resolves those initialisation problems.

You're still zero initializingn them in the new diff ;-(

> I was actually thinking that the main drawback of this appoach was the
> extra space devoted to these variables. Marking them as __init made the
> linker very unhappy. Given their current delaration, will they just
> stick around forever?
> 

Yous hould be able to mark them __init, otherwise they just end up
sticking around forever as you say. Grep around some other code in the
vicinity to see how it's declared if it causes problems.

Cheers,
Jes
