From: "David S. Miller" <davem@redhat.com>
Date: Fri, 06 Sep 2002 03:19:35 +0000
Subject: Re: [Linux-ia64] Re: patch for IA64: fix do_sys32_msgrcv bad
Message-Id: <marc-linux-ia64-105590701906015@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906014@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906014@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Don Dugger <n0ano@n0ano.com>
   Date: Thu, 5 Sep 2002 10:43:12 -0600

   Yes, but Dave Millier claims that this patch is still broken, he says the
   fix needs to be in `ipc_kludge'.  I don't have access to my source tree
   until this evening, have you looked at this?
   
You didn't read David's patch at all, this is exactly what he is
doing, fixing the ipc_kludge declaration.

   On Thu, Sep 05, 2002 at 09:51:48AM -0700, David Mosberger wrote:
   > diff -Nru a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
   > --- a/arch/ia64/ia32/sys_ia32.c	Thu Sep  5 09:51:05 2002
   > +++ b/arch/ia64/ia32/sys_ia32.c	Thu Sep  5 09:51:05 2002
   > @@ -2111,8 +2111,8 @@
   >  };
   >  
   >  struct ipc_kludge {
   > -	struct msgbuf *msgp;
   > -	long msgtyp;
   > +	u32 msgp;
   > +	s32 msgtyp;
   >  };
   >  
   >  #define SEMOP		 1

See?

