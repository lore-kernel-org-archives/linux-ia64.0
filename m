From: Steve Christiansen <smc@us.ibm.com>
Date: Thu, 21 Mar 2002 20:02:32 +0000
Subject: Re: [Linux-ia64] Trouble building cross compilers
Message-Id: <marc-linux-ia64-105590701905313@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905309@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905309@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 20, 2002 at 06:30:47PM -0800, Jesse Barnes wrote:
> I have a couple of questions about cross compiling with gcc 3.0:
> 
> 1) is it possible to build an x86 hosted gcc 3.0 ia64 cross compiler
>    without nue?  Or, which packages do I need to build a gcc cross
>    compiler?

I've not been able to build an x86 to ia64 cross compiler using 3.0
"out of the box".  I have a patch for 3.0.4 in the tarball at

http://www.ibm.com/developerworks/oss/linux/tools/

which seems to work.  It's a hack, so no guarantees.

The 3.1 pre-release branch works fine, so you might consider using CVS
or a pre-release snapshot.  See http://gcc.gnu.org

The gcc mailing list thread beginning with the following may also
be helpful.

http://gcc.gnu.org/ml/gcc/2002-02/msg00585.html

And here's another useful resource, if you haven't already discovered it:

http://www.objsw.com/CrossGCC/


-- 
Steve Christiansen <smc@us.ibm.com>
IBM Linux Technology Center
503-578-4177  IBM T/L: 775-4177
http://www.ibm.com/linux/ltc

