From: Segher Boessenkool <segher@kernel.crashing.org>
Date: Fri, 11 Feb 2022 07:39:19 +0000
Subject: Re: [PATCH v3 04/12] powerpc: Prepare func_desc_t for refactorisation
Message-Id: <20220211073919.GW614@gate.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634457599.git.christophe.leroy@csgroup.eu> <86c393ce0a6f603f94e6d2ceca08d535f654bb23.1634457599.git.christophe.leroy@csgroup.eu> <202202101653.9128E58B84@keescook>
In-Reply-To: <202202101653.9128E58B84@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Helge Deller <deller@gmx.de>, linux-kernel@vger.kernel.org, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org

On Thu, Feb 10, 2022 at 04:54:52PM -0800, Kees Cook wrote:
> On Sun, Oct 17, 2021 at 02:38:17PM +0200, Christophe Leroy wrote:
(edited:)
> > +typedef struct {
> > +	unsigned long addr;
> > +} func_desc_t;
> >  
> >  static func_desc_t func_desc(unsigned long addr)
> >  {
> > +	return (func_desc_t){addr};

> There's only 1 element in the struct, so okay, but it hurt my eyes a
> little. I would have been happier with:
> 
> 	return (func_desc_t){ .addr = addr; };
> 
> But of course that also looks bonkers because it starts with "return".
> So no matter what I do my eyes bug out. ;)

The usual way to avoid convoluted constructs is to name more factors.
So:

static func_desc_t func_desc(unsigned long addr)
{
	func_desc_t desc = {};
	desc.addr = addr;
	return desc;
}


Segher
