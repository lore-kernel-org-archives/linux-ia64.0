From: "H . J . Lu" <hjl@valinux.com>
Date: Fri, 15 Sep 2000 15:38:23 +0000
Subject: Re: [Linux-ia64] setjmp/longjmp : flushing register stack
Message-Id: <marc-linux-ia64-105590678205496@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205495@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205495@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 15, 2000 at 04:17:55PM +0100, SCHAN@uk.ibm.com wrote:
> 
> 
> Hello,
> 
> We are developing the Linux/IA64 Java VM and we need sigsetjmp/setjmp
> flushing the register stack properly - however currently it only flush on
> the call of longjmp - is there any chance of adding flushrs into
> setjmp/sigsetjmp? We could do it in our code but there will be rather
> inconvenient...
> 

Post a patch. You have the source code. I will take a look to see if I
can include it in my ia64 glibc patch.


-- 
H.J. Lu (hjl@gnu.org)

