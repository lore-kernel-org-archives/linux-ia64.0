From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 24 Oct 2003 17:10:44 +0000
Subject: Re: Itanium2@900MHz slower than alpha@666MHz ?
Message-Id: <marc-linux-ia64-106701576831217@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106700871121653@msgid-missing>
In-Reply-To: <marc-linux-ia64-106700871121653@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ionut,

On Fri, Oct 24, 2003 at 06:26:55PM +0200, Ionut Georgescu wrote:
> Yes, it is a 1.5MB cache CPU.
> 
> But it might be more than just cache misses. When running with a 256x256
> grid, I am actually using 3 256x257 matrices, which is slightly over
> 1.5MB.  I just made a comparison with a 32x32 grid and the difference is
> the same: alpha 10.294s, zx2000 14.777s . -O3 is only by 0.4s faster
> than -O2 in this case.
> 
Another thing to check is the syslog. Check to see if your program 
is not getting "floating point software assist" fault. That can slow
you down significantly.

-- 
-Stephane
