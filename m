From: martin sepulveda <martin@ojf.com>
Date: Thu, 17 Apr 2003 23:59:54 +0000
Subject: Re: [Linux-ia64] floating-point error
Message-Id: <marc-linux-ia64-105590723705556@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705538@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705538@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

it does not write anything about this on the alert log, and neither does it on a trace file.


m.

On Thu, 17 Apr 2003 14:12:40 -0700
"Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:

> Oracle has its own exception handler.  It usually dumps out more
> information in its alert file.  Look in $ORACLE_HOME/rdbms/log/*.log for
> more clue.
> 
> - Ken
> 

