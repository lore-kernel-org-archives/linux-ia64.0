From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 26 Jun 2003 01:27:07 +0000
Subject: Re: IA-32 support patch: fcntl64 calls are broken
Message-Id: <marc-linux-ia64-105659088004085@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105649509512709@msgid-missing>
In-Reply-To: <marc-linux-ia64-105649509512709@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 25 Jun 2003 11:18:17 -0700 Arun Sharma <arun.sharma@intel.com>
wrote:
>
> Bjorn Helgaas wrote:
> > 2.5 has this code, which looks suspicious to me (do we really mean
> > to call sys_fcntl() twice?):
> 
> Cc'ing the author of this patch in 2.5. Stephen, did you mean to call
> sys_fcntl() twice ?

No. Rats! :-(  Cut and paste error (I assume).  I will submit a patch
to Linus.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
