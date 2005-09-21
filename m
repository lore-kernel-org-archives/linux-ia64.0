From: Gary Hade <garyhade@us.ibm.com>
Date: Wed, 21 Sep 2005 20:23:59 +0000
Subject: Re: ia64 dispersal analysis capability
Message-Id: <20050921202359.GD4692@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050921182143.GA30873@sgi.com>
In-Reply-To: <20050921182143.GA30873@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 21, 2005 at 01:23:43PM -0500, Jack Steiner wrote:
> In 2002, Gary Hade posted a patch to binutils that added dispersal
> analysis to the output of objdump. 

That was a long time ago. :)

> Does anyone know what happened to the patch? 

I think it may have died due to lack of interest.  I'm 
not aware many folks like you that have actually been
using it.

At the time, I obtained a FSF copyright assignment for 
the code at the request of one of the binutils maintainers.
AFAIK the patch was never incorporated although I do 
not remember seeing any technical concerns from the 
binutils maintainers before I moved on to a different 
project.

> Is there another tool that provides the same information?

Not that I'm aware of.
The binutils patch was based on an earlier stand-alone utility 
that processed `objdump -d` output but that program lacked 
Itanium 2 support and several other improvements that I put
in the binutils version.  I can't remember very much about the
code but I suspect that some of these changes would not have 
been adaptable to the stand-alone utility.

> 
> I've found the tool very useful for providing insight into IA64
> code scheduling. 

Thanks.  We thought it might be useful to someone.

Gary

-- 
Gary Hade
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

