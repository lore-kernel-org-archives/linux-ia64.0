From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 30 Aug 2006 16:48:49 +0000
Subject: Re: [RFC][PATCH 01/10] put alignment macros in align.h
Message-Id: <1156956529.12898.10.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060829201934.A5363374@localhost.localdomain>
In-Reply-To: <20060829201934.A5363374@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2006-08-30 at 20:11 +0400, Nikita Danilov wrote:
> Dave Hansen writes:
>  > + */
>  > +#ifndef __ASSEMBLY__
>  > +#define ALIGN(x,a) (((x)+(a)-1)&~((a)-1))
> 
> This evaluates (a) twice. While in all existing call-sites (a) is
> probably a constant, it's still safer to do
> 
> #define ALIGN(x,a) ({ typeof(a) __a = (a); (((x) + __a - 1) & ~(__a - 1)); })
> 
> in a generic macro and rely on compiler to optimize temporary variable
> out.

Looks great to me.  I'll incorporate it for the next version. 

-- Dave

