From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 02 Sep 2000 04:00:57 +0000
Subject: Re: [Linux-ia64] new toolchain snapshots
Message-Id: <marc-linux-ia64-105590678205448@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205422@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205422@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 01 Sep 2000 20:01:21 -0700, 
Jim Wilson <wilson@cygnus.com> wrote:
>	Compiling the 2.4.0-test7 code for fs/nfs/dir.c with this snapshot
>	generates an unresolved reference to __multi3, for no reason that I can
>	see. 
>
>There is no reference to __multi3.  Only a declaration for it.  The .s file has
>      .globl __multi3
>This causes it to be put in the symbol table where nm can see it, but does
>not result in any relocation for it because we aren't using it.  This should
>be harmless.

It breaks modutils, depmod assumes that all unresolved externals in a
module are actually used.  I will complain to the modutils maintainer,
hang on, that's me :(.


